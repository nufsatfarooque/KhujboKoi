import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'image_widget.dart';

class DishDetailSheet extends StatefulWidget {
  final String restaurantId;
  final Map<String, dynamic> dish;
  final VoidCallback onReviewSubmitted;

  const DishDetailSheet({
    super.key,
    required this.restaurantId,
    required this.dish,
    required this.onReviewSubmitted,
  });

  @override
  State<DishDetailSheet> createState() => _DishDetailSheetState();
}

class _DishDetailSheetState extends State<DishDetailSheet> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 3.0;
  bool _isSubmitting = false;
  bool _isRestaurantOwner = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  @override
  void dispose() {
    _reviewController.dispose();
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

  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a review')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firestore.collection('reviews').add({
          'restaurantId': widget.restaurantId,
          'dishName': widget.dish['dish_name'],
          'content': _reviewController.text.trim(),
          'rating': _rating.round(),
          'submittedAt': FieldValue.serverTimestamp(),
          'userId': user.uid,
          'userName': user.displayName ?? 'Anonymous',
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review submitted successfully!')),
          );
          widget.onReviewSubmitted();
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.dish['image'] != null)
              ImageWidget(image: widget.dish['image'], height: 200),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    widget.dish['dish_name'] ?? 'Unknown Dish',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  Text(
                    'Price: ৳${widget.dish['price'] ?? 'N/A'}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (!_isRestaurantOwner) ...[
              Text(
                'Rating: ${_rating.round()} stars',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.green[800],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_border, color: Colors.amber),
                  Expanded(
                    child: Slider(
                      value: _rating,
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: _rating.round().toString(),
                      onChanged: (value) {
                        setState(() {
                          _rating = value;
                        });
                      },
                    ),
                  ),
                  const Icon(Icons.star, color: Colors.amber),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _reviewController,
                decoration: InputDecoration(
                  labelText: 'Write a review',
                  labelStyle: GoogleFonts.poppins(color: Colors.green[800]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.green[800]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.green[800]!),
                  ),
                  hintText: 'Share your experience with this dish...',
                ),
                maxLines: 3,
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ] else ...[
              Center(
                child: Text(
                  'As a restaurant owner, you can only view dish details.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}