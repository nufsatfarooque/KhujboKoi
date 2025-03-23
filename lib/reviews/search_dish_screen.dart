import 'package:flutter/material.dart';
import 'dart:convert'; // For Base64 decoding
import 'firestore_service.dart'; // Import the Firestore service
import 'restaurant_specific_review.dart'; // Import the restaurant-specific review screen
import 'package:flutter_animate/flutter_animate.dart'; // For animations

class SearchDishScreen extends StatefulWidget {
  const SearchDishScreen({super.key});

  @override
  _SearchDishScreenState createState() => _SearchDishScreenState();
}

class _SearchDishScreenState extends State<SearchDishScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String _sortBy = 'rating'; // Default sorting option

  // Custom color scheme
  final Color _primaryColor = Color(0xFF4CAF50); // Green
  final Color _backgroundColor = Color(0xFFF5F5F5); // Whitish background
  final Color _cardColor = Colors.white; // Card background
  final Color _textColor = Colors.black87; // Text color

  Future<void> _searchDishes(String query) async {
    setState(() {
      _isLoading = true;
    });

    final results = await FirestoreService.searchDishes(query);

    results.sort((a, b) {
      switch (_sortBy) {
        case 'rating':
          return b['rating'].compareTo(a['rating']);
        case 'price_low_to_high':
          return a['price'].compareTo(b['price']);
        case 'price_high_to_low':
          return b['price'].compareTo(a['price']);
        default:
          return 0;
      }
    });

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'Search Dishes',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ).animate().fadeIn(duration: 500.ms),
        backgroundColor: _primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Input Field and Button with Animation
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for a dish...',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: _primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _primaryColor, width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {
                      _searchDishes(_searchController.text);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter a dish name')),
                      );
                    }
                  },
                  icon: Icon(Icons.search, size: 20),
                  label: Text('Search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ],
            ).animate().slideY(begin: -0.5, end: 0, duration: 600.ms, curve: Curves.easeOut),
          ),
          // Sorting Dropdown with Icon
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.sort, color: _primaryColor, size: 20),
                SizedBox(width: 8),
                Text(
                  'Sort by:',
                  style: TextStyle(fontSize: 16, color: _textColor, fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 8),
                DropdownButton<String>(
                  value: _sortBy,
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                    _searchDishes(_searchController.text);
                  },
                  dropdownColor: _cardColor,
                  icon: Icon(Icons.arrow_drop_down, color: _primaryColor),
                  style: TextStyle(color: _textColor, fontSize: 16),
                  items: [
                    DropdownMenuItem(value: 'rating', child: Text('Rating')),
                    DropdownMenuItem(value: 'price_low_to_high', child: Text('Price: Low to High')),
                    DropdownMenuItem(value: 'price_high_to_low', child: Text('Price: High to Low')),
                  ],
                ),
              ],
            ).animate().fadeIn(delay: 200.ms),
          ),
          // Dish List or Loading/No Results
          Expanded(
            child: _isLoading
                ? _buildShimmerLoading()
                : _searchResults.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sentiment_dissatisfied, size: 60, color: _primaryColor.withOpacity(0.5)),
                  SizedBox(height: 16),
                  Text(
                    'No dishes found.',
                    style: TextStyle(color: _textColor, fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ).animate().scaleXY(begin: 0.8, end: 1.0, delay: 300.ms),
            )
                : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final dish = _searchResults[index];
                final imageBytes = dish['image'] != null ? base64Decode(dish['image']) : null;

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RestaurantSpecificReview(
                            restaurantId: dish['restaurantId'],
                          ),
                        ),
                      ).then((_) => _searchDishes(_searchController.text));
                    },
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
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
                              color: _primaryColor.withOpacity(0.1),
                              child: Icon(Icons.fastfood, size: 40, color: _primaryColor),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dish['dish_name'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _textColor,
                                  ),
                                ).animate().slideX(begin: -0.2, end: 0, duration: 400.ms),
                                SizedBox(height: 6),
                                Text(
                                  'Restaurant: ${dish['restaurantName']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _textColor.withOpacity(0.7),
                                  ),
                                ).animate().fadeIn(delay: 100.ms),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.attach_money, size: 16, color: _primaryColor),
                                    SizedBox(width: 4),
                                    Text(
                                      '৳${dish['price']}',
                                      style: TextStyle(fontSize: 16, color: _primaryColor),
                                    ),
                                  ],
                                ).animate().fadeIn(delay: 150.ms),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.star, size: 16, color: Colors.amber[700]),
                                    SizedBox(width: 4),
                                    Text(
                                      '${dish['rating']} ⭐',
                                      style: TextStyle(fontSize: 14, color: Colors.amber[700]),
                                    ),
                                  ],
                                ).animate().fadeIn(delay: 200.ms),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: (index * 100).ms).scaleXY(
                  begin: 0.95,
                  end: 1.0,
                  duration: 300.ms,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Shimmer Loading Effect
  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 18,
                        color: _primaryColor.withOpacity(0.1),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: 120,
                        height: 14,
                        color: _primaryColor.withOpacity(0.1),
                      ),
                      SizedBox(height: 6),
                      Container(
                        width: 80,
                        height: 14,
                        color: _primaryColor.withOpacity(0.1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate(
          onPlay: (controller) => controller.repeat(),
        ).shimmer(duration: 1000.ms).scaleXY(
          begin: 0.98,
          end: 1.0,
          duration: 800.ms,
        );
      },
    );
  }
}