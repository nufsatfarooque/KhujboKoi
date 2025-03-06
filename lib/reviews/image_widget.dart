import 'package:flutter/material.dart';
import 'dart:convert';

class ImageWidget extends StatelessWidget {
  final String? image;
  final double height;

  const ImageWidget({super.key, required this.image, this.height = 200});

  @override
  Widget build(BuildContext context) {
    if (image == null || image!.isEmpty) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.image_not_supported, size: 50, color: Colors.white),
      );
    }

    return GestureDetector(
      onTap: () {
        _showExpandedImage(context, image!);
      },
      child: Hero(
        tag: image!, // Unique tag for Hero animation
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            base64Decode(image!), // Decode Base64 string
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.broken_image, size: 50, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load image',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showExpandedImage(BuildContext context, String base64Image) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context); // Close the dialog when tapped
            },
            child: Hero(
              tag: base64Image, // Same tag as the original image
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  base64Decode(base64Image),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}