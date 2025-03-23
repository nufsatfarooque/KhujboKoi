//firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Search for dishes by name across all restaurants
  static Future<List<Map<String, dynamic>>> searchDishes(String query) async {
    final querySnapshot = await _firestore
        .collection('restaurant_info')
        .get();

    final List<Map<String, dynamic>> dishes = [];

    // Loop through each restaurant
    for (var restaurantDoc in querySnapshot.docs) {
      final restaurantData = restaurantDoc.data();
      final List<dynamic> restaurantDishes = restaurantData['dishes'];

      // Loop through each dish in the restaurant
      for (var dish in restaurantDishes) {
        if (dish['dish_name'].toString().toLowerCase().contains(query.toLowerCase())) {
          // Add dish to the results list
          final dishData = Map<String, dynamic>.from(dish);
          dishData['restaurantId'] = restaurantDoc.id; // Add restaurant ID for reference
          dishData['restaurantName'] = restaurantData['restaurant_name']; // Add restaurant name
          dishes.add(dishData);
        }
      }
    }

    // Fetch reviews for each dish and calculate average rating
    for (var dish in dishes) {
      final reviews = await _fetchReviewsForDish(dish['dish_name']);
      final averageRating = _calculateAverageRating(reviews);
      dish['rating'] = double.parse(averageRating.toStringAsFixed(1)); // Round to one decimal place
    }

    return dishes;
  }

  // Fetch reviews for a specific dish
  static Future<List<Map<String, dynamic>>> _fetchReviewsForDish(String dishName) async {
    final querySnapshot = await _firestore
        .collection('reviews')
        .where('dishName', isEqualTo: dishName)
        .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  // Calculate average rating for a dish
  static double _calculateAverageRating(List<Map<String, dynamic>> reviews) {
    if (reviews.isEmpty) return 0.0;

    double totalRating = 0.0;
    for (var review in reviews) {
      totalRating += review['rating'];
    }

    return totalRating / reviews.length;
  }
}