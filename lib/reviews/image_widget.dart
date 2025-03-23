import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

// Helper class to cache decoded images
class _ImageCache {
  static final Map<String, Uint8List> _cache = {};

  static Uint8List getImage(String base64String) {
    if (!_cache.containsKey(base64String)) {
      _cache[base64String] = base64Decode(base64String);
    }
    return _cache[base64String]!;
  }
}

class ImageWidget extends StatelessWidget {
  final String? image;
  final double height;
  final double? width;
  final BoxFit fit;

  const ImageWidget({
    super.key,
    required this.image,
    this.height = 200,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (image == null || image!.isEmpty) {
      return Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.image_not_supported, size: 50, color: Colors.white),
      );
    }

    // Use cached image data
    final imageData = _ImageCache.getImage(image!);

    // Avoid setting cacheHeight/cacheWidth to preserve original resolution
    return GestureDetector(
      onTap: () {
        _showExpandedImage(context, image!);
      },
      child: Hero(
        tag: image!, // Unique tag for Hero animation
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            imageData,
            height: height,
            width: width ?? double.infinity,
            fit: fit,
            gaplessPlayback: true, // Prevents flicker during reload
            // Removed cacheHeight and cacheWidth to avoid downscaling
            errorBuilder: (context, error, stackTrace) => Container(
              height: height,
              width: width ?? double.infinity,
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
        final imageData = _ImageCache.getImage(base64Image);
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Hero(
              tag: base64Image,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  imageData,
                  fit: BoxFit.contain,
                  // Removed cacheHeight to avoid downscaling
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}