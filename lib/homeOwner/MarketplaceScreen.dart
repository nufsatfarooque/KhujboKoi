// MarketplaceScreen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  _MarketplaceScreenState createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> availableListings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAvailableListings();
  }

  Future<void> _fetchAvailableListings() async {
    try {
      QuerySnapshot listingsSnapshot = await _firestore
          .collection('listings')
          .where('approved', isEqualTo: true)
          .where('processed', isEqualTo: true)
          .get();

      availableListings.clear();
      for (var doc in listingsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        availableListings.add({
          'id': doc.id,
          'buildingName': data['buildingName'] ?? "Unknown",
          'rent': data['rent'] ?? "N/A",
          'description': data['description'] ?? "No Description",
          'address': data['address'] ?? "No Address",
          'images': List<String>.from(data['images'] ?? []),
          'rating': data['rating'] ?? 0.0,
          'bedrooms': data['bedrooms'] ?? 0,
          'bathrooms': data['bathrooms'] ?? 0,
          'amenities': data['amenities'] ?? "",
          'processed': data['processed'] ?? false,
          'approved': data['approved'] ?? false,
        });
      }
    } catch (e) {
      print("Error fetching marketplace listings: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : availableListings.isEmpty
          ? const Center(child: Text("No available properties found"))
          : GridView.builder(
        padding: const EdgeInsets.all(15),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 cards per row
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8, // Adjust height relative to width
        ),
        itemCount: availableListings.length,
        itemBuilder: (context, index) {
          var listing = availableListings[index];
          return Card(
            elevation: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (listing['images'].isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    child: Image.memory(
                      base64Decode(listing['images'][0]),
                      height: 100, // Thumbnail size
                      width: double.infinity,
                      fit: BoxFit.cover,
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
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.attach_money, color: Colors.green, size: 14),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              "${listing['rent']} TK",
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            "${listing['rating']}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}