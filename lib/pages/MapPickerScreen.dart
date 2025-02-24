import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const MapPickerScreen({Key? key, this.initialLocation}) : super(key: key);
  // Expose the getUserLocation method via the StatefulWidget
  Future<LatLng> getUserLocation() async {
    // Access the state instance and call the method
    final state = _MapPickerScreenState();
    await state.getUserLocation(); // Call the method from the state
    return state.currentLocation;
  }
  @override
  _MapPickerScreenState createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng currentLocation;
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  Future<void> getUserLocation() async {
    Location location = Location();

    // Check location service
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Check location permissions
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return; // Exit if permissions are not granted
      }
    }

    // Get current location
    LocationData locationData = await location.getLocation();
    setState(() {
      currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
    });

    // Move the camera to the user's location
    if (mapController != null && currentLocation != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLocation!, zoom: 15),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (currentLocation != null) {
                Navigator.pop(context, currentLocation); // Return the selected location
              }
            },
          ),
        ],
      ),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator()) // Show loader while fetching location
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: currentLocation!,
          zoom: 15,
        ),
        onTap: (LatLng position) {
          setState(() {
            currentLocation = position; // Update selected location
          });
        },
        markers: {
          Marker(
            markerId: const MarkerId("selected-location"),
            position: currentLocation!,
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
      ),
    );
  }
}