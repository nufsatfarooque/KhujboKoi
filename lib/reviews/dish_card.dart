//dishcard
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'image_widget.dart';

class DishCard extends StatelessWidget {
  final Map<String, dynamic> dish;
  final VoidCallback onPressed;

  const DishCard({super.key, required this.dish, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (dish['image'] != null) ImageWidget(image: dish['image'], height: 150),
          ListTile(
            title: Text(
              dish['dish_name'] ?? 'Unknown dish',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            subtitle: Text(
              '৳${dish['price'] ?? 'Price not available'}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.green[600],
              ),
            ),
            trailing: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()..scale(1.0),
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Review',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}