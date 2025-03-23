import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

class HouseSpecificReview extends StatefulWidget {
  final String buildingName;
  final String address;

  const HouseSpecificReview({required this.buildingName, required this.address, super.key});

  @override
  State<HouseSpecificReview> createState() => _HouseReviewState();
}

class _HouseReviewState extends State<HouseSpecificReview> {
  final TextEditingController _reviewController = TextEditingController();
  final PageController _pageController = PageController();
  double _userRating = 0.0;
  double _hoverRating = 0.0; // For hover effect
  Map<String, dynamic>? _houseInfo;
  List<Map<String, dynamic>>? _reviews;
  bool _isLoadingHouseInfo = true;
  bool _isSubmittingReview = false; // To control shimmer during review submission
  bool _isFetchingReviews = false; // To control shimmer during review fetching

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // Load house info
    setState(() => _isLoadingHouseInfo = true);
    _houseInfo = await getHouseInfo();
    setState(() => _isLoadingHouseInfo = false);

    // Load reviews separately
    _reviews = await getReviews();
  }

  Future<Map<String, dynamic>> getHouseInfo() async {
    final firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore
        .collection('listings')
        .where('buildingName', isEqualTo: widget.buildingName)
        .where('address', isEqualTo: widget.address)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data() as Map<String, dynamic>;
    } else {
      return {
        'buildingName': widget.buildingName,
        'address': widget.address,
        'description': 'No information available.',
        'images': [],
      };
    }
  }

  Future<List<Map<String, dynamic>>> getReviews() async {
    setState(() => _isFetchingReviews = true); // Start shimmer for reviews
    final firestore = FirebaseFirestore.instance;
    final reviewsQuery = await firestore
        .collection('house_reviews')
        .where('houseId', isEqualTo: '${widget.buildingName} - ${widget.address}')
        .get();
    setState(() => _isFetchingReviews = false); // Stop shimmer for reviews
    return reviewsQuery.docs.map((doc) => doc.data()).toList();
  }

  Future<void> submitReview(String content, double rating) async {
    setState(() => _isSubmittingReview = true); // Start shimmer for submission
    final firestore = FirebaseFirestore.instance;
    final currentUserId = 'your_user_id'; // Replace with actual user ID

    final review = {
      'houseId': '${widget.buildingName} - ${widget.address}',
      'userId': currentUserId,
      'content': content,
      'rating': rating,
      'timestamp': Timestamp.fromDate(DateTime.now()),
    };

    await firestore.collection('house_reviews').add(review);

    // Only refresh reviews after submitting, not the entire house info
    _reviews = await getReviews();

    setState(() => _isSubmittingReview = false); // Stop shimmer for submission
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.buildingName),
        backgroundColor: Colors.green,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.green.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Show shimmer only for house info section when loading
            _isLoadingHouseInfo
                ? _buildHouseInfoShimmer()
                : _houseInfo != null
                ? _buildHouseInfoSection(_houseInfo!)
                : const SizedBox.shrink(),
            const Divider(thickness: 1.0),
            _buildReviewSection(),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Add your action here
      //   },
      //   backgroundColor: Colors.green,
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
    );
  }

  Widget _buildHouseInfoShimmer() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 200,
              height: 24,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5, // Number of list tiles
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _reviewController,
            decoration: const InputDecoration(
              labelText: 'Write a Review',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.comment, color: Colors.green),
            ),
            maxLines: null,
          ),
        ),
        _buildStarRating(),
        ElevatedButton(
          onPressed: _isSubmittingReview
              ? null // Disable button while submitting
              : () {
            final reviewContent = _reviewController.text;
            if (reviewContent.isNotEmpty) {
              submitReview(reviewContent, _userRating);
              _reviewController.clear();
              setState(() => _userRating = 0.0);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          child: _isSubmittingReview
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Text('Submit Review', style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
        const Divider(thickness: 1.0),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Reviews',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Only show shimmer for reviews section when fetching reviews
        if (_isFetchingReviews)
          _buildReviewShimmer()
        else if (_reviews != null && _reviews!.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _reviews!.length,
            itemBuilder: (context, index) {
              final review = _reviews![index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text('${review['rating']}/5', style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(review['content'], style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('yyyy-MM-dd – kk:mm').format((review['timestamp'] as Timestamp).toDate()),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.5);
            },
          )
        else
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'No reviews yet. Be the first to review!',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildReviewShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: List.generate(3, (index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 120,
                    height: 12,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStarRating() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          return MouseRegion(
            onEnter: (_) => setState(() => _hoverRating = index + 1.0),
            onExit: (_) => setState(() => _hoverRating = 0.0),
            child: GestureDetector(
              onTap: () => setState(() => _userRating = index + 1.0),
              child: Icon(
                index < (_hoverRating > 0 ? _hoverRating : _userRating) ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 32,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHouseInfoSection(Map<String, dynamic> info) {
    final images = info['images'] as List<dynamic>? ?? [];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (images.isNotEmpty)
            Column(
              children: [
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                body: PhotoView(
                                  imageProvider: MemoryImage(base64Decode(images[index])),
                                ),
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(
                            base64Decode(images[index]),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: images.length,
                  effect: const WormEffect(dotHeight: 8, dotWidth: 8, activeDotColor: Colors.green),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Text(
            'House Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          ListTile(
            leading: const Icon(Icons.location_on, color: Colors.green),
            title: Text('Address: ${info['address']}'),
          ),
          ListTile(
            leading: const Icon(Icons.description, color: Colors.green),
            title: Text('Description: ${info['description']}'),
          ),
          ListTile(
            leading: const Icon(Icons.bed, color: Colors.green),
            title: Text('Bedrooms: ${info['bedrooms']}'),
          ),
          ListTile(
            leading: const Icon(Icons.bathtub, color: Colors.green),
            title: Text('Bathrooms: ${info['bathrooms']}'),
          ),
          ListTile(
            leading: const Icon(Icons.wallet, color: Colors.green),
            title: Text('Rent: ৳${info['rent']}'),
          ),
        ],
      ),
    );
  }
}