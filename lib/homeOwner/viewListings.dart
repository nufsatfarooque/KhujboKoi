import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:khujbokoi/homeOwner/EditListings.dart';
class ViewListings extends StatefulWidget {
  const ViewListings({super.key});

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
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists && userDoc['listings'] != null) {
          List<dynamic> listingIds = userDoc['listings'];
          userListings.clear(); // Clear previous listings before adding new ones

          for (String listingId in listingIds) {
            DocumentSnapshot listingDoc =
            await _firestore.collection('listings').doc(listingId).get();

            if (listingDoc.exists) {
              Map<String, dynamic> listingData = listingDoc.data() as Map<String, dynamic>;

              // Ensure images are stored as Strings, not MemoryImage
              List<String> base64Images = List<String>.from(listingData['images'] ?? []);

              userListings.add({
                'id': listingId,
                'buildingName': listingData['buildingName'] ?? "Unknown",
                'rent': listingData['rent'] ?? "N/A",
                'description': listingData['description'] ?? "No Description",
                'address': listingData['address'] ?? "No Address",
                'images': base64Images, // Store Base64 Strings
                'rating': listingData['rating'] ?? 0.0,
                'bedrooms': listingData['bedrooms'] ?? 0,
                'bathrooms': listingData['bathrooms'] ?? 0,
                'approved': listingData['approved'] ?? false,
              });
            }
          }
        }
      }
    } catch (e) {
      print("Error fetching listings: $e");
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
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text("Edit"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditListingScreen(listingId: listing['id']),
                            ),
                          );
                        },

                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text("Delete"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => deleteListing(listing['id']),
                      ),
                    ],
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
