// lib/homeOwner/viewListings.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:khujbokoi/homeOwner/EditListings.dart';
import '../services/rent_predictor.dart'; // Import RentPredictor

class ViewListings extends StatefulWidget {
  const ViewListings({super.key});

  @override
  _ViewListingsState createState() => _ViewListingsState();
}

class _ViewListingsState extends State<ViewListings> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RentPredictor _rentPredictor = RentPredictor(); // Initialize RentPredictor
  List<Map<String, dynamic>> userListings = []; // To store user listings
  bool isLoading = true; // To manage loading state

  @override
  void initState() {
    super.initState();
    _rentPredictor.loadModel(); // Load the model coefficients from Firestore
    _fetchUserListings(); // Fetch the listings when the screen is loaded
  }

  // Fetch user's listings and predict rents
  Future<void> _fetchUserListings() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists && userDoc['listings'] != null) {
          List<dynamic> listingIds = userDoc['listings'];
          userListings.clear(); // Clear previous listings before adding new ones

          for (String listingId in listingIds) {
            DocumentSnapshot listingDoc = await _firestore.collection('listings').doc(listingId).get();

            if (listingDoc.exists) {
              Map<String, dynamic> listingData = listingDoc.data() as Map<String, dynamic>;

              // Only add listings with rentStatus: 0
              if (listingData['rentStatus'] == 0) {
                // Predict rent using RentPredictor
                double predictedRent = _rentPredictor.predictRent(
                  bedrooms: listingData['bedrooms'] ?? 0,
                  bathrooms: listingData['bathrooms'] ?? 0,
                  latitude: listingData['addressonmap']?['latitude'] ?? 0.0,
                  longitude: listingData['addressonmap']?['longitude'] ?? 0.0,
                );

                userListings.add({
                  'id': listingId,
                  'buildingName': listingData['buildingName'] ?? "Unknown",
                  'rent': listingData['rent'] ?? "N/A",
                  'description': listingData['description'] ?? "No Description",
                  'address': listingData['address'] ?? "No Address",
                  'images': List<String>.from(listingData['images'] ?? []),
                  'rating': listingData['rating'] ?? 0.0,
                  'bedrooms': listingData['bedrooms'] ?? 0,
                  'bathrooms': listingData['bathrooms'] ?? 0,
                  'approved': listingData['approved'] ?? false,
                  'rentStatus': listingData['rentStatus'] ?? 0,
                  'predictedRent': predictedRent, // Add predicted rent
                });
              }
            }
          }
        }
      }
    } catch (e) {
      print("Error fetching listings: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching listings: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteListing(String listingId) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Remove the listing from the 'listings' collection
        await _firestore.collection('listings').doc(listingId).delete();

        // Remove the listing ID from the user's 'listings' array
        await _firestore.collection('users').doc(user.uid).update({
          'listings': FieldValue.arrayRemove([listingId])
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Listing deleted successfully")));

        // Refresh listings after deletion
        _fetchUserListings();
      }
    } catch (e) {
      print("Error deleting listing: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting listing: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Listings", style: TextStyle(color: Colors.green)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userListings.isEmpty
          ? const Center(child: Text("No listings found"))
          : ListView.builder(
        itemCount: userListings.length,
        itemBuilder: (context, index) {
          var listing = userListings[index];
          bool isApproved = listing['approved'] ?? false; // Check if the listing is approved

          return Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🏠 Building Name
                  Text(
                    listing['buildingName'] ?? "No Name",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 📍 Address
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red, size: 18),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          listing['address'],
                          style: const TextStyle(fontSize: 14, color: Colors.black54),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 💰 Rent
                  Row(
                    children: [
                      const Icon(Icons.attach_money, color: Colors.green, size: 18),
                      const SizedBox(width: 5),
                      Text(
                        "${listing['rent']} TK / month",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Predicted Rent
                  Row(
                    children: [
                      const Icon(Icons.trending_up, color: Colors.green, size: 18),
                      const SizedBox(width: 5),
                      Text(
                        "Suggested: ${listing['predictedRent'].round()} TK",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),

                  // 🛏 Bedrooms & 🚿 Bathrooms
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bed, color: Colors.blue, size: 18),
                          const SizedBox(width: 5),
                          Text("${listing['bedrooms']} Bedrooms"),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.bathtub, color: Colors.blue, size: 18),
                          const SizedBox(width: 5),
                          Text("${listing['bathrooms']} Bathrooms"),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),

                  // ⭐ Rating & ✅ Approval
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 5),
                          Text("${listing['rating']} Rating"),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            listing['approved'] ? Icons.check_circle : Icons.cancel,
                            color: listing['approved'] ? Colors.green : Colors.red,
                            size: 18,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            listing['approved'] ? "Approved" : "Not Approved",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: listing['approved'] ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),

                  // 🖼 Images
                  if (listing['images'] != null && listing['images'].isNotEmpty)
                    GridView.builder(
                      itemCount: listing['images'].length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, imgIndex) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            base64Decode(listing['images'][imgIndex]),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 10),

                  // ✏️ Edit & 🗑 Delete Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Edit Button
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text("Edit"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditListingScreen(listingId: listing['id']),
                            ),
                          );

                          // Refresh the list if the listing was updated
                          if (result == true) {
                            _fetchUserListings();
                          }
                        },
                      ),

                      // Delete Button
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text("Delete"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => deleteListing(listing['id']),
                      ),
                    ],
                  ),

                  // ✅ Mark as Rented Button (on a new line)
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text("Mark as Rented"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isApproved ? Colors.green : Colors.grey, // Grey if not approved
                      ),
                      onPressed: isApproved
                          ? () async {
                        await _firestore.collection('listings').doc(listing['id']).update({
                          'rentStatus': 1, // Update rentStatus to 1 (rented)
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Property marked as rented")),
                        );
                        _fetchUserListings(); // Refresh the list
                      }
                          : null, // Disable button if not approved
                    ),
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
