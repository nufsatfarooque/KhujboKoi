import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:khujbokoi/chat%20screen/models/user_profile.dart';
import 'dart:convert';
import 'package:khujbokoi/chat%20screen/pages/chat_page.dart';

class HouseDetailsPage extends StatefulWidget {
  final String houseId;
  final double userLatitude;
  final double userLongitude;
  
  const HouseDetailsPage({
    super.key,
    required this.houseId,
    required this.userLatitude,
    required this.userLongitude,
  });

  @override
  State<HouseDetailsPage> createState() => _HouseDetailsPageState();
}

class _HouseDetailsPageState extends State<HouseDetailsPage> {
  final GetIt _getIt=GetIt.instance;
  Map<String, dynamic> houseDetails = {};
  double distance = 0.0;
  LatLng position = LatLng(0.0, 0.0);
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    getHouseDetails();
  }

  //chatgpt gave this

  Future<UserProfile?> getUserProfile(String email) async {
  try {
    print("Fetching user profile for: $email"); // Debugging statement

    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      print("User found: ${query.docs.first.data()}"); // Debugging statement
      return UserProfile.fromJson(query.docs.first.data() as Map<String, dynamic>);
    } else {
      print("No user found with username: $email"); // Debugging statement
    }
  } catch (e) {
    print('Error fetching user profile: $e');
  }
  return null;
}


  


  Future<void> getHouseDetails() async {
    try {
      DocumentSnapshot house = await FirebaseFirestore.instance
          .collection('listings')
          .doc(widget.houseId)
          .get();

      if (!house.exists) return;

      setState(() {
        houseDetails = house.data() as Map<String, dynamic>;
        var address = houseDetails['addressonmap'];

        if (address is GeoPoint) {
          position = LatLng(address.latitude, address.longitude);
        } else if (address is Map<String, dynamic>) {
          position = LatLng(address['latitude'], address['longitude']);
        }

        distance = Geolocator.distanceBetween(
                widget.userLatitude,
                widget.userLongitude,
                position.latitude,
                position.longitude) /
            1000;
      });
    } catch (e) {
      print('Error fetching house details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (houseDetails.isEmpty) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      //backgroundColor: const Color.fromARGB(255, 240, 240, 240),
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
        title: const Text("KhujboKoi?", style: TextStyle(color: Colors.green)),
        backgroundColor: Colors.transparent,
        actions: const [
          SizedBox(
            width: 50,
            height: 50,
            child: Icon(Icons.menu, color: Colors.green),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNameCard(Icons.home, "Name", houseDetails['buildingName'] ?? "No name"),
              SizedBox(height: 10),
              if (houseDetails['images'] != null && houseDetails['images'] is List && (houseDetails['images'] as List).isNotEmpty)
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 250,
                        width: double.infinity,
                        child: PageView.builder(
                          itemCount: (houseDetails['images'] as List).length,
                          onPageChanged: (index) {
                            setState(() {
                              currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Image.memory(
                              base64Decode((houseDetails['images'] as List)[index]),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 100, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          (houseDetails['images'] as List).length, 
                          (index) => Container(
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            width: currentPage == index ? 12 : 8,
                            height: currentPage == index ? 12 : 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentPage == index ? Colors.green : Colors.grey,
                            ),
                          ),
                          ),
                        ),
                    ),
                  ],
                ),
              SizedBox(height: 16),
              // _buildInfoCard(Icons.home, "Name", houseDetails['buildingName'] ?? "No name"),
              _buildInfoRow([
                _buildInfoCard(Icons.category, "Type", houseDetails['type'] ?? "N/A"),
                _buildInfoCard(Icons.star, "Rating", houseDetails['rating']?.toString() ?? "N/A"),
              ]),
              _buildInfoRow([
                _buildInfoCard(Icons.bed, "Bedrooms", houseDetails['bedrooms']?.toString() ?? "N/A"),
                _buildInfoCard(Icons.bathtub, "Bathrooms", houseDetails['bathrooms']?.toString() ?? "N/A"),
              ]),
              _buildInfoCard(Icons.attach_money, "Rent", "${houseDetails['rent'] ?? 'N/A'} BDT"),
              _buildInfoCard(Icons.location_on, "Address", houseDetails['address'] ?? "N/A"),
              _buildInfoCard(Icons.description, "Description", houseDetails['description'] ?? "No description"),
              _buildInfoCard(Icons.directions_walk, "Distance", "${distance.toStringAsFixed(2)} km"),
              SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(target: position, zoom: 14),
                    markers: {
                      Marker(markerId: MarkerId('house'), position: position, infoWindow: InfoWindow(title: houseDetails['buildingName'])),
                      Marker(markerId: MarkerId('user'), position: LatLng(widget.userLatitude, widget.userLongitude), infoWindow: InfoWindow(title: 'Your Location'), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose)),
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 8,
                  ),

                  //Chatgpt gave this
                  onPressed: () async {
                    if (houseDetails['username'] != null) {
                      UserProfile? ownerProfile = await getUserProfile(houseDetails['username']);
                      if (ownerProfile != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                          builder: (context) => ChatPage(chatUser: ownerProfile),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("User not found")),
                        );
                      }
                    }
                  },


                  // onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(
                  //     chatUser: houseDetails['username'],
                  // ))),
                  icon: Icon(Icons.chat),
                  label: Text("Chat with Owner", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.green, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(
                      text: "$title: ",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    TextSpan(text: value),
                  ],
                ),
              ),
            ),
          ],
        ),
        
      ),
    );
  }

  Widget _buildNameCard(IconData icon, String title, String value) {
  return Card(
    margin: EdgeInsets.symmetric(vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 3,
    shadowColor: Colors.green,
    child: Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisSize: MainAxisSize.max, // Ensures minimal space usage
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.green, size: 26),
          SizedBox(width: 8), // Reduce spacing
          Text(
            value,
            style: TextStyle(fontSize: 23, color: Colors.black, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}


  

  Widget _buildInfoRow(List<Widget> children) {
    
    return Row(
      children: children.expand((e) => [Expanded(child: e), SizedBox(width: 10)]).toList()..removeLast(),
    );
  }
}
