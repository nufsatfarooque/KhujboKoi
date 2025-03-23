// lib/services/data_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchListingData() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('listings').get();
      List<Map<String, dynamic>> data = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> listing = doc.data() as Map<String, dynamic>;
        if (listing.containsKey('rent') &&
            listing.containsKey('bedrooms') &&
            listing.containsKey('bathrooms') &&
            listing.containsKey('addressonmap')) {
          data.add({
            'rent': double.parse(listing['rent'].toString()),
            'bedrooms': listing['bedrooms'],
            'bathrooms': listing['bathrooms'],
            'latitude': listing['addressonmap']['latitude'],
            'longitude': listing['addressonmap']['longitude'],
          });
        }
      }
      return data;
    } catch (e) {
      print('Error fetching listing data: $e');
      return [];
    }
  }
}