import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dish_detail_sheet.dart'; // Import the DishDetailSheet
import 'image_widget.dart'; // Import the updated ImageWidget

class RestaurantSpecificReview extends StatefulWidget {
  final String restaurantId;

  const RestaurantSpecificReview({
    super.key,
    required this.restaurantId,
  });

  @override
  State<RestaurantSpecificReview> createState() => _RestaurantSpecificReviewState();
}

class _RestaurantSpecificReviewState extends State<RestaurantSpecificReview>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PageController _pageController = PageController();
  late TabController _tabController;

  Map<String, dynamic>? _restaurantData;
  List<Map<String, dynamic>> _reviews = [];
  String? _restaurantImage;
  String? _menuImage;
  bool _isLoading = true;
  bool _isFetchingReviews = false;
  String? _error;
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;
  bool _isRestaurantOwner = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    _checkUserStatus();

    _scrollController.addListener(() {
      setState(() {
        _showTitle = _scrollController.offset > 200;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkUserStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _isRestaurantOwner = doc.data()?['restaurant_owner'] ?? false;
        });
      }
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Future.wait([
        _fetchRestaurantInfo(),
        _fetchReviews(),
      ]);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchRestaurantInfo() async {
    try {
      final docSnapshot = await _firestore
          .collection('restaurant_info')
          .doc(widget.restaurantId)
          .get();

      if (docSnapshot.exists && mounted) {
        final data = docSnapshot.data()!;
        setState(() {
          _restaurantData = data;

          if (data['images'] != null && data['images'] is List) {
            for (var image in data['images']) {
              if (image is Map<String, dynamic>) {
                if (image['image_type'] == 'restaurant') {
                  _restaurantImage = image['image'];
                } else if (image['image_type'] == 'menu') {
                  _menuImage = image['image'];
                }
              }
            }
          }

          if (_restaurantImage != null) {
            precacheImage(MemoryImage(base64Decode(_restaurantImage!)), context);
          }
          if (_menuImage != null) {
            precacheImage(MemoryImage(base64Decode(_menuImage!)), context);
          }
          if (data['dishes'] != null) {
            for (var dish in data['dishes']) {
              if (dish['image'] != null) {
                precacheImage(MemoryImage(base64Decode(dish['image'])), context);
              }
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error fetching restaurant info: $e';
        });
      }
    }
  }

  Future<void> _fetchReviews() async {
    setState(() => _isFetchingReviews = true);
    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('restaurantId', isEqualTo: widget.restaurantId)
          .get();

      if (mounted) {
        setState(() {
          _reviews = querySnapshot.docs.map((doc) => doc.data()).toList();
          _reviews.sort((a, b) {
            final aTime = a['submittedAt'] as Timestamp?;
            final bTime = b['submittedAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error fetching reviews: $e';
        });
      }
    } finally {
      setState(() => _isFetchingReviews = false);
    }
  }

  void _showDishDetails(Map<String, dynamic> dish) {
    if (_isRestaurantOwner) return; // Prevent restaurant owners from opening the sheet

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: DishDetailSheet(
            restaurantId: widget.restaurantId,
            dish: dish,
            onReviewSubmitted: _loadData,
          ),
        ),
      ),
    );
  }

  double _getRatingAverage() {
    if (_reviews.isEmpty) return 0;
    double total = 0;
    int count = 0;
    for (var review in _reviews) {
      if (review['rating'] != null) {
        total += review['rating'];
        count++;
      }
    }
    return count > 0 ? total / count : 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green[800]!),
              ),
              const SizedBox(height: 16),
              Text(
                "Loading restaurant details...",
                style: GoogleFonts.poppins(
                  color: Colors.green[800],
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(duration: 600.ms),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red[700],
                size: 56,
              ).animate().shakeX(duration: 600.ms),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.red[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ).animate().fadeIn(delay: 200.ms),
            ],
          ),
        ),
      );
    }

    final double averageRating = _getRatingAverage();
    final bool hasReviews = _reviews.isNotEmpty;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.green[800],
              foregroundColor: Colors.white,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              flexibleSpace: FlexibleSpaceBar(
                title: _showTitle
                    ? Text(
                  _restaurantData?['restaurant_name'] ?? 'Restaurant',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                )
                    : null,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    ImageWidget(
                      image: _restaurantImage,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _restaurantData?['restaurant_name'] ?? 'Restaurant',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    offset: const Offset(1, 1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green[800],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        averageRating.toStringAsFixed(1),
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  hasReviews ? '(${_reviews.length} reviews)' : 'No reviews yet',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.only(bottom: 8),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.green[800],
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: Colors.green[800],
                  indicatorWeight: 3,
                  labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(icon: Icon(Icons.info_outline), text: "Info"),
                    Tab(icon: Icon(Icons.restaurant_menu), text: "Menu"),
                    Tab(icon: Icon(Icons.rate_review), text: "Reviews"),
                  ],
                ),
              ).animate().slideY(begin: 0.2, duration: 300.ms),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildInfoTab(),
            _buildMenuTab(),
            _buildReviewsTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _tabController.animateTo(2);
        },
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.rate_review),
        label: const Text('View Reviews'),
      ).animate().slideY(begin: 1, duration: 400.ms, curve: Curves.easeOutQuad),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shadowColor: Colors.green.withOpacity(0.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _restaurantData?['description'] ?? 'No description available',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            shadowColor: Colors.green.withOpacity(0.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[50],
                      child: Icon(Icons.location_on, color: Colors.green[800]),
                    ),
                    title: Text('Address', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                    subtitle: Text(
                      _restaurantData?['location'] ?? 'Not available',
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[50],
                      child: Icon(Icons.access_time, color: Colors.green[800]),
                    ),
                    title: Text('Hours', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                    subtitle: Text(
                      _restaurantData?['hours'] ?? '9:00 AM - 10:00 PM',
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[50],
                      child: Icon(Icons.phone, color: Colors.green[800]),
                    ),
                    title: Text('Phone', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                    subtitle: Text(
                      _restaurantData?['contact_number'] ?? 'Not available',
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[50],
                      child: Icon(Icons.language, color: Colors.green[800]),
                    ),
                    title: Text('Website', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                    subtitle: Text(
                      _restaurantData?['website'] ?? 'Not available',
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideX(begin: 0.1),
          const SizedBox(height: 16),
          if (_restaurantData?['tags'] != null) ...[
            Card(
              elevation: 4,
              shadowColor: Colors.green.withOpacity(0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cuisine',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (var tag in _restaurantData!['tags'])
                          Chip(
                            avatar: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: Icon(Icons.restaurant, size: 16, color: Colors.green[800]),
                            ),
                            label: Text(tag),
                            backgroundColor: Colors.green[50],
                            labelStyle: GoogleFonts.poppins(
                              color: Colors.green[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_menuImage != null) ...[
            Card(
              elevation: 4,
              shadowColor: Colors.green.withOpacity(0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.menu_book, color: Colors.green[800]),
                        const SizedBox(width: 8),
                        Text(
                          'Full Menu',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                appBar: AppBar(
                                  title: const Text('Menu'),
                                  backgroundColor: Colors.green[800],
                                ),
                                body: PhotoView(
                                  imageProvider: MemoryImage(base64Decode(_menuImage!)),
                                ),
                              ),
                            ),
                          );
                        },
                        child: ImageWidget(
                          image: _menuImage,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Tap to enlarge',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 24),
          ],
          Text(
            'Popular Dishes',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 12),
          if (_restaurantData?['dishes'] != null && _restaurantData!['dishes'].isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _restaurantData!['dishes'].length,
              itemBuilder: (context, index) {
                final dish = _restaurantData!['dishes'][index];
                final double rating = dish['rating'] ?? 0.0;
                return Card(
                  key: ValueKey(dish['dish_name']),
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shadowColor: Colors.green.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    onTap: _isRestaurantOwner ? null : () => _showDishDetails(dish), // Disable tap for owners
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (dish['image'] != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child: ImageWidget(
                                  image: dish['image'],
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          else
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.restaurant, size: 40, color: Colors.green[800]),
                            ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        dish['dish_name'] ?? 'Dish Name',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[800],
                                        ),
                                      ),
                                    ),
                                    if (rating > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.amber[100],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.star, color: Colors.amber, size: 14),
                                            const SizedBox(width: 2),
                                            Text(
                                              rating.toString(),
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.amber[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '৳${dish['price'] ?? 'N/A'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.1);
              },
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.no_food, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No dishes available',
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          if (_isRestaurantOwner)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                "As a restaurant owner, you can only view dish details and reviews.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shadowColor: Colors.green.withOpacity(0.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getRatingAverage().toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < _getRatingAverage().floor() ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 24,
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Based on ${_reviews.length} reviews',
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer Reviews',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.sort, color: Colors.green[800]),
                tooltip: 'Sort reviews',
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isFetchingReviews)
            _buildReviewShimmer()
          else if (_reviews.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shadowColor: Colors.green.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.green[50],
                              child: Icon(Icons.person, color: Colors.green[800]),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review['userName'] ?? 'Anonymous',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: List.generate(5, (starIndex) {
                                      return Icon(
                                        starIndex < (review['rating'] ?? 0) ? Icons.star : Icons.star_border,
                                        color: Colors.amber,
                                        size: 16,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              DateFormat('dd MMM yyyy').format((review['submittedAt'] as Timestamp).toDate()),
                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          review['content'] ?? 'No review content',
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 12),
                        if (review['dishName'] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.restaurant, size: 16, color: Colors.green[800]),
                                const SizedBox(width: 8),
                                Text(
                                  'Dish: ${review['dishName']}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.green[800],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.1);
              },
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.reviews, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      _isRestaurantOwner
                          ? 'No reviews yet for this restaurant.'
                          : 'No reviews yet. Be the first to review!',
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(3, (index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(backgroundColor: Colors.grey[300]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 120, height: 16, color: Colors.grey[300]),
                            const SizedBox(height: 8),
                            Container(width: 100, height: 12, color: Colors.grey[300]),
                          ],
                        ),
                      ),
                      Container(width: 80, height: 12, color: Colors.grey[300]),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(width: double.infinity, height: 14, color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Container(width: double.infinity, height: 14, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Container(width: 150, height: 12, color: Colors.grey[300]),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}