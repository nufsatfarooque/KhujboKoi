import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'rental_houses.dart'; // Ensure this file contains the RentalHouse class
import 'house_data.dart';    // Ensure this file has house data
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui' as ui;

class MapPage extends StatefulWidget {
  final LatLng? address;//passed parameter
  final String addressString;
  const MapPage({Key? key, required this.address, required this.addressString}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  //static const LatLng _pIUT = LatLng(23.94748, 90.380);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  LatLng? _currentLocation;
  String _currentLocationText = "Location : ";
  late GoogleMapController mapController;
  BitmapDescriptor? customIcon; // Holds the custom icon
  Marker? _currentLocationMarker;
  Set<Marker> _markers = {}; //store all addresses from firebase


  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
    _markerAndCameraOnCurrLoc(widget.address, widget.addressString);//converts the address passed from home to the map loc
    //_getUserLocation(); //Fetch the users current location
    _fetchAddressFromFirebase(); //Fetch house addresses from firebase
  }


// Load the custom marker icon
  Future<void> _loadCustomMarker() async {
    try {
      // Load the image from assets
      ByteData byteData = await rootBundle.load('assets/home.png');
      ui.Codec codec = await ui.instantiateImageCodec(
        byteData.buffer.asUint8List(),
        targetWidth: 120, // Set the desired width
        targetHeight: 120, // Set the desired height
      );
      ui.FrameInfo frameInfo = await codec.getNextFrame();

      // Convert to BitmapDescriptor
      ByteData? resizedByteData =
      await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
      if (resizedByteData != null) {
        BitmapDescriptor resizedIcon = BitmapDescriptor.fromBytes(
          resizedByteData.buffer.asUint8List(),
        );

        // Set the custom icon
        setState(() {
          customIcon = resizedIcon;
        });
      }
    } catch (e) {
      print("Error loading custom marker: $e");
    }
  }


  //fetch the users location
  Future<void> _getUserLocation() async {
    Location location = Location();

    //check location service enabled
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }


    // Check for location permissions
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return; // Exit if permissions are not granted
      }
    }

    //get current location
    LocationData locationData = await location.getLocation();
    setState(() {
      _currentLocation =
          LatLng(locationData.latitude!, locationData.longitude!);
      _currentLocationText =
      "Lat: ${locationData.latitude}, Lng: ${locationData.longitude}";
      //add marker to current location
      _currentLocationMarker = Marker(
        markerId: const MarkerId("current_location"),
        position: _currentLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(20),
        infoWindow: const InfoWindow(title: "You are here"),
      );
      _markers.add(_currentLocationMarker!);
    });
    //move camera to user's location
    if (mapController != null && _currentLocation != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentLocation!, zoom: 16),
        ),
      );
    }
  }

  //Fetch the address latitude and longitude from firebase
  Future<void> _fetchAddressFromFirebase() async {
    try {
      CollectionReference listings = _firestore.collection('listings');
      QuerySnapshot querySnapshot = await listings.get();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print("Fetched data: $data"); // Debugging

        if (data['addressonmap'] != null) {
          var address = data['addressonmap'];
          LatLng position;

          if (address is GeoPoint) {
            position = LatLng(address.latitude, address.longitude);
          } else if (address is Map<String, dynamic>) {
            position = LatLng(address['latitude'], address['longitude']);
          } else {
            print("Invalid addressonmap format: $address");
            continue;
          }

          String markerId = doc.id;

          // Create marker
          Marker marker = Marker(
            markerId: MarkerId(markerId),
            position: position,
            icon: customIcon ?? BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(title: data['title'] ?? "No Title"),
          );

          setState(() {
            _markers.add(marker);
          });
        } else {
          print("Document ${doc.id} does not have 'addressonmap'");
        }
      }
    } catch (e) {
      print("Error fetching markers from Firebase: $e");
    }
  }


  // Create markers for rental houses
  Set<Marker> _createMarkers() {
    return rentalHouses.map((house) {
      return Marker(
        markerId: MarkerId(house.id),
        position: LatLng(house.latitude, house.longitude),
        icon: BitmapDescriptor.defaultMarker,
        //customIcon ?? BitmapDescriptor.defaultMarker,  // Use custom icon if loaded
        onTap: () {
          _showHouseDetails(house); // Show details on marker tap
        },
      );
    }).toSet();
  }

  // Show the house details in a modal bottom sheet
  void _showHouseDetails(RentalHouse house) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                house.houseName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Owner: ${house.ownerName}"),
                  Text("Rating: ${house.rating}/5"),
                ],
              ),
              SizedBox(height: 5),
              Text("Contact: ${house.ownerContact}"),
              SizedBox(height: 5),
              Text("Available Flats: ${house.availableFlats}"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Add navigation functionality here if needed
                  Navigator.pop(context); // Close the modal
                },
                child: Text("Navigate Here"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rental Houses Near You"),
      ),
      body: Stack(
        children: [
          _currentLocation == null ? const Center(
              child: CircularProgressIndicator()) //show loader while fetching
              : GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation!,
              zoom: 16,
            ),
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
          ),
          //Display current location text at bottom
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12.0),
              color: Colors.white.withOpacity(0.8),
              child: Text(
                _currentLocationText,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addressToLatlng(String address) async {
    try {
      // Geocode the address
      List<geo.Location> locations = await geo.locationFromAddress(address);
      print("The locations is :" + locations.reversed.toString());
      if (locations.isNotEmpty) {
        _currentLocation = LatLng(locations.first.latitude, locations.first.longitude);
        //_markerAndCameraOnCurrLoc(_currentLocation);
      }
    } catch (e) {
      print("Error converting address: $e");
    }
  }

  Future<void> _latLngToAddress(LatLng? latlng) async {
    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
          latlng!.latitude, latlng.longitude);

      if (placemarks.isNotEmpty) {
        geo.Placemark placemark = placemarks.first;
        _currentLocationText =
        '${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, '
            '${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, '
            '${placemark.postalCode}, ${placemark.country}';
        //'${placemark.name}, ${placemark.locality}, ${placemark.country}';
      } else {
        print("No address found for given coordinates");
      }
    }catch (e) {
      print("Error converting latlng:  $e");
    }
  }


  Future<void> _markerAndCameraOnCurrLoc(LatLng? currentLocation, String address) async {
    _currentLocation = currentLocation;
    _currentLocationText += address;
    setState(() {
      //_latLngToAddress(currentLocation);
      //"Lat: ${_currentLocation?.latitude}, Lng: ${_currentLocation?.longitude}";
      //add marker to current location
      _currentLocationMarker = Marker(
        markerId: const MarkerId("current_location"),
        position: currentLocation!,
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: const InfoWindow(title: "You are here"),
      );
      _markers.add(_currentLocationMarker!);
    });
    //move camera to user's location
    if (mapController != null && currentLocation != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLocation!, zoom: 16),
        ),
      );
    }
  }
}
