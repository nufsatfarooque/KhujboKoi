import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'restaurant_specific_review.dart';

class RestaurantReview extends StatelessWidget {
  const RestaurantReview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Restaurants in Boardbazar',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.shade700, // Starting color
                Colors.green.shade300, // Ending color
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent, // Make the AppBar background transparent to show the gradient
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('restaurant_info').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No restaurants found.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              );
            }

            final restaurants = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: restaurants.length,
              itemBuilder: (context, index) {
                final restaurantData = restaurants[index].data() as Map<String, dynamic>;

                // Extract restaurant name
                final restaurantName = restaurantData['restaurant_name'] ?? 'Unknown';

                // Extract other restaurant details
                final restaurantAddress = restaurantData['location'] ?? 'No address available';
                final restaurantDescription = restaurantData['description'] ?? 'No description available';

                // Extract restaurant image (image_type == 'restaurant')
                final images = restaurantData['images'] as List<dynamic>? ?? [];
                final restaurantImage = images.firstWhere(
                      (img) => img['image_type'] == 'restaurant',
                  orElse: () => null,
                );

                final imageBytes = restaurantImage != null
                    ? base64Decode(restaurantImage['image'])
                    : null;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 4,
                  child: InkWell(
                    onTap: () {
                      // Navigate to RestaurantSpecificReview and pass the restaurantId
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RestaurantSpecificReview(restaurantId: restaurants[index].id),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.green.shade100, Colors.white],
                        ),
                      ),
                      child: Row(
                        children: [
                          // Restaurant Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: imageBytes != null
                                ? Image.memory(
                              imageBytes,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                                : Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(
                                  Icons.restaurant,
                                  size: 32,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          // Restaurant Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  restaurantName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  restaurantAddress,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  restaurantDescription,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Arrow Icon
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}