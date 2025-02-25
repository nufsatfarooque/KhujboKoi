import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:khujbokoi/pages/map_page.dart';
import 'package:khujbokoi/routes/bottomnav.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khujbokoi/screen/onboarding_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;

class HomePage extends StatefulWidget {
  final VoidCallback onLoginPress;
  const HomePage({super.key, required this.onLoginPress});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> allListing = []; //all listings
  List<Map<String, dynamic>> filteredListings = [];
  bool isLoading = true;
  bool _isDropdownVisible = false;
  final TextEditingController _controller = TextEditingController();
  var uuid= Uuid();
  String sessionToken = '1234';
  List<dynamic> _placesList = [];
  bool _showList = true; //visibility of listview
  double searchLatitude = 0.0;
  double searchLongitude = 0.0;
  LatLng? currentLocation;
  LatLng? controllerLatlng;
  late GoogleMapController mapController;
  String _currentLocationString = "";

  @override
  void initState() {
    super.initState();
    _fetchAllListings();
    getUserLocation();


    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.green, // Status bar color
      ),
    );

    _controller.addListener(() {
      onChange();
    });

  }
    // Set the status bar color to green

    //Fetch all listings from firebase
    Future<void> _fetchAllListings() async {
      try {
        //query listings collection
        QuerySnapshot listingSnapshot = await _firestore.collection('listings')
            .get();

        for (var listingDoc in listingSnapshot.docs) {
          Map<String, dynamic> listingData = listingDoc.data() as Map<
              String,
              dynamic>;

          // Debug log
          print("Listing fetched: ${listingData['addressonmap']}");
          // Convert Base64 images to Image widgets
          List<MemoryImage> images = [];
          List<dynamic> base64Images = listingData['images'];
          for (var base64String in base64Images) {
            var imageBytes = base64Decode(base64String);
            images.add(MemoryImage(imageBytes));
          }

          //add listings data to the list
          allListing.add({
            'buildingName': listingData['buildingName'],
            'rent': listingData['rent'],
            'description': listingData['description'],
            'address': listingData['address'],
            'addressonmap' : listingData['addressonmap'],
            'images': images,
            'rating': listingData['rating'],
          });
        }
      } catch (e) {
        print("Error fetching listings: $e");
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }

  //   Future<void> _getUserLocation() async {
  //     try {
  //       // Safely wait for the widget to be mounted before calling setState
  //       if (mounted) {
  //         final location = await gettingCurrentLocation_.getUserLocation();
  //         setState(() {
  //           _currentLocationString = location;
  //           getAddressFromLatlng(_currentLocationString);
  //         });
  //       }
  //     } catch (e) {
  //       print("Error fetching user location: $e");
  //     }
  //     // Ensure that the widget is mounted before calling setState
  //     // await Future.delayed(Duration.zero, () {
  //     //   if (mounted) {
  //     //     setState(() {
  //     //       _currentLocationString = gettingCurrentLocation_.getUserLocation() as LatLng;
  //     //       getAddressFromLatlng(_currentLocationString);
  //     //     });
  //     //   }
  //     // });
  //     _controller.text = '';
  // }
  Future<void> getUserLocation() async {
    loc.Location location = loc.Location();

    // Check location service
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Check location permissions
    loc.PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return; // Exit if permissions are not granted
      }
    }

    // Get current location
    loc.LocationData locationData = await location.getLocation();
    setState(() {
      currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
    });
    getAddressFromLatlng(currentLocation);
  }

  Future<void> getAddressFromLatlng(LatLng? latlng) async {
    try{
      //placemark from lat lng coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(latlng!.latitude, latlng.longitude);

      if(placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        _currentLocationString = '${placemark.name}, ${placemark.locality}, ${placemark.country}';
        _filterListings(_currentLocationString);
      } else {
        print("No address found for given coordinates");
      }
    } catch(e) {
      print("Error occurred while reverse geocoding: $e");
    }

  }

  double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadiusKm = 6371.0;

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  Future<void> _filterListings(String address) async {
    try {
      // Geocode the address
      List<Location> locations = await locationFromAddress(address);
      print("The locations is :${locations.reversed}");

      if (locations.isNotEmpty) {
        searchLatitude = locations.first.latitude;
        searchLongitude = locations.first.longitude;

        print("Searched");
        print(searchLatitude);
        print(searchLongitude);

        // Filter listings within 5000 sq. km (70.7 km radius)
        setState(() {
          filteredListings = allListing.where((listing) {
            if (listing['addressonmap'] != null) {
              var address = listing['addressonmap'];
              LatLng position;

              // Determine the type of 'addressonmap' and extract LatLng
              if (address is GeoPoint) {
                position = LatLng(address.latitude, address.longitude);
              } else if (address is Map<String, dynamic>) {
                position = LatLng(address['latitude'], address['longitude']);
              } else {
                print("Invalid addressonmap format: $address");
                return false; // Skip this listing
              }

              // Calculate distance
              double distance = calculateDistance(
                  searchLatitude, searchLongitude, position.latitude, position.longitude);

              print("Distance for listing: $distance km"); // Debug log
              return distance <= 70.7; // 70.7 km radius
            }
            
            print("NULL????");
            // Debugging why addressonmap might be null
            print("Listing skipped due to null addressonmap: $listing");
            return false; // Skip listings with null 'addressonmap'
          }).toList();
        });
      }
    } catch (e) {
      print("Error filtering listings: $e");
    }
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownVisible = !_isDropdownVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[Color(0xFF7FE38D), Colors.white],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        title: const Text("KhujboKoi?", style: TextStyle(color: Colors.green)),
        backgroundColor: Colors.transparent,
        actions: [
          SizedBox(
            width: 50,
            height: 50,
            child: const Icon(Icons.menu, color: Colors.green),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
         await _addressToLatlng(_controller.text); //converting the controller value to latlng and passing to map if it is not empty
          LatLng? locationToSend = _controller.text.isEmpty ? currentLocation : controllerLatlng;
          String addressToSend = _controller.text.isEmpty ? _currentLocationString : _controller.text;
          Navigator.push(
              context,
            MaterialPageRoute(
                builder: (context)=> MapPage(address: locationToSend, addressString: addressToSend,),
            ),
          );
        },
        backgroundColor: Color(0x8C77CB73),
        child: const Icon(Icons.maps_home_work),
      ),
      body:
      Padding(
        padding: const EdgeInsets.all(25.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Search places with name'
                      ),
                      onChanged: (value) {
                        setState(() {
                          _showList = value.isNotEmpty;
                          // if(value.isEmpty)
                          //   {
                          //     _filterListings(_currentLocationString);
                          //   } else {
                          //   _filterListings(value);
                          // }
                        });
                        getSuggestion(value);
                      },
                      onFieldSubmitted: (value) {
                        _filterListings(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            if(_showList)
            Expanded(child: ListView.builder(
              itemCount: _placesList.length,
                itemBuilder: (context, index){
                  return ListTile(
                    onTap: ()async{
                      List<Location> locations = await locationFromAddress(_placesList[index]['description']);

                      //update the text field and hide the list
                      setState(() {
                        _controller.text = _placesList[index]['description'];
                        _showList = false;
                      });

                      //print(locations.last.latitude);
                     // print(locations.last.longitude);
                    },
                    title: Text(_placesList[index]['description']),
                  );
              })
            ),
            const SizedBox(height: 20),
            _controller.text == ''
                ? Text('Current Location: $_currentLocationString', style: TextStyle(fontSize: 16))
                : const SizedBox.shrink(),
            const SizedBox(height: 20),
            // Property Grid with Buttons
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredListings.isEmpty
                      ? const Center(child: Text("No listing available"))
                      : GridView.builder(
                          padding: const EdgeInsets.only(top: 10),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, //2 listings per row
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: filteredListings.length,
                          itemBuilder: (context, index){
                            var listing = filteredListings[index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(//ekhane new house view er file ta add korte hbe
                                    builder: (context) => OnboardingScreen(),
                                  ),
                                );
                              },
                              child: Card(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                          ),
                                          child: Image.memory(
                                            listing['images'].isNotEmpty
                                                ? listing['images'][0].bytes
                                                : Uint8List(0),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        ),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              listing['buildingName'],
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold, fontSize: 16),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 5),
                                            Text("Rent: ${listing['rent']}"),
                                            Text("Rating: ${listing['rating']}"),
                                            const SizedBox(height: 5),
                                            Text(
                                              listing['description'],
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                      ),
            ),
          ],
        ),

      ),
  

    ),
    );
  }

  void onChange() {
    getSuggestion(_controller.text);
  }

  void getSuggestion(String input) async {
    String placesApiKey = "AIzaSyDGHhGjKrKCnYujl1YkRilpbUk2P1IMzCM";
    String baseURL='https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request = '$baseURL?input=$input&key=$placesApiKey&sessiontoken=$sessionToken';

    var response = await http.get(Uri.parse(request));
    //var data = response.body.toString();

    //print('data');
    //print(data);
    if(response.statusCode == 200){
      setState(() {
        _placesList = jsonDecode(response.body.toString()) ['predictions'];
      });
    }else {
      throw Exception('Failed to load data');
    }
  }
  //convert address from places api to latlng value
  Future<void> _addressToLatlng(String address) async {
    try {
      // Geocode the address
      List<Location> locations = await locationFromAddress(address);
      print("The latlng for address is :${locations.reversed}");
      if (locations.isNotEmpty) {
        controllerLatlng = LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      print("Error converting address: $e");
    }
  }
}


