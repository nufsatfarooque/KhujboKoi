//This code defines a Property class that creates a property object containing
//info about each listings

import 'package:cloud_firestore/cloud_firestore.dart';

class Property {
  final String address;
  final double latitude;
  final double longitude;
  final bool approved;
  final String buildingName;
  final String description;
  final List<String> images;
  final double rating;
  final String rent;
  final DateTime timestamp;
  final String type;
  final String username;
  final String id;
  
  Property({
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.approved,
    required this.buildingName,
    required this.description,
    required this.images,
    required this.rating,
    required this.rent,
    required this.timestamp,
    required this.type,
    required this.username, 
    required this.id,
  });

  factory Property.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Property(
      address: data['address'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      approved: data['approved'] ?? false,
      buildingName: data['buildingName'] ?? '',
      description: data['description'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      rating: (data['rating'] ?? 0).toDouble(),
      rent: data['rent'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      type: data['type'] ?? '',
      username: data['username'] ?? '',
      id: doc.id,
    );
  }

  
}