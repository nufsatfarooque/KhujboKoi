// lib/services/rent_predictor.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class RentPredictor {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<double>? coefficients;
  double? intercept;

  Future<void> loadModel() async {
    try {
      DocumentSnapshot modelDoc = await _firestore.collection('models').doc('rent_predictor').get();
      if (modelDoc.exists) {
        Map<String, dynamic> data = modelDoc.data() as Map<String, dynamic>;
        coefficients = (data['coefficients'] as List<dynamic>).map((e) => e as double).toList();
        intercept = data['intercept'] as double;
      }
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  double predictRent({
    required int bedrooms,
    required int bathrooms,
    required double latitude,
    required double longitude,
  }) {
    if (coefficients == null || intercept == null) {
      throw Exception('Model not loaded');
    }

    List<double> features = [bedrooms.toDouble(), bathrooms.toDouble(), latitude, longitude];
    double prediction = intercept!;
    for (int i = 0; i < coefficients!.length; i++) {
      prediction += coefficients![i] * features[i];
    }
    return prediction > 0 ? prediction : 0;
  }
}