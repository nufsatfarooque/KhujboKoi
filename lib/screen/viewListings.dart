import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ViewListings extends StatefulWidget {
  @override
  _ViewListingsState createState() => _ViewListingsState();
}

class _ViewListingsState extends State<ViewListings> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> userListings = []; // To store user listings
  bool isLoading = true; // To manage loading state

  @override
  void initState() {
    super.initState();
    _fetchUserListings(); // Fetch the listings when the screen is loaded
  }

  // Fetch user's listings
  Future<void> _fetchUserListings() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Fetch the user's document from the 'users' collection
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists && userDoc['listings'] != null) {
          List<dynamic> listingIds = userDoc['listings'];

          // Fetch each listing's data
          for (String listingId in listingIds) {
            DocumentSnapshot listingDoc = await _firestore.collection('listings').doc(listingId).get();
            if (listingDoc.exists) {
              Map<String, dynamic> listingData = listingDoc.data() as Map<String, dynamic>;

              // Convert Base64 images to Image widgets
              List<MemoryImage> images = [];
              List<dynamic> base64Images = listingData['images'];
              for (var base64String in base64Images) {
                var imageBytes = base64Decode(base64String);
                images.add(MemoryImage(imageBytes));
              }

              // Add listing data to the list
              userListings.add({
                'buildingName': listingData['buildingName'],
                'rent': listingData['rent'],
                'description': listingData['description'],
                'address': listingData['address'],
                'images': images,
                'rating': listingData['rating'],
              });
            }
          }
        }
      }
    } catch (e) {
      // Handle error if fetching data fails
      print("Error fetching listings: $e");
    } finally {
      setState(() {
        isLoading = false; // Stop loading when data is fetched
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "KhujboKoi?",
              style: TextStyle(color: Colors.green),
            ),
            const Text(
              "                               My Listings",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 7,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.green,
              size: 35,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : userListings.isEmpty
          ? const Center(child: Text("No listings found"))
          : ListView.builder(
        itemCount: userListings.length,
        itemBuilder: (context, index) {
          var listing = userListings[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing['buildingName'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text("Rent: ${listing['rent']}"),
                  Text("Address: ${listing['address']}"),
                  const SizedBox(height: 5),
                  Text("Description: ${listing['description']}"),
                  const SizedBox(height: 10),
                  Text("Rating: ${listing['rating']}"),
                  const SizedBox(height: 10),
                  GridView.builder(
                    itemCount: listing['images'].length,
                    shrinkWrap: true, // Prevent GridView from taking infinite height
                    physics: const NeverScrollableScrollPhysics(), // Disable scrolling for GridView
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Show two images per row
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1, // Make images square
                    ),
                    itemBuilder: (context, imgIndex) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          listing['images'][imgIndex].bytes,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
