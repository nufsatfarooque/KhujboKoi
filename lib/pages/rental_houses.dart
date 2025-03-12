// lib/rental_house.dart

class RentalHouse {
  final String id;
  final String houseName;
  final String ownerName;
  final String ownerContact;
  final int availableFlats;
  final double latitude;
  final double longitude;
  final double rating;

  RentalHouse({
    required this.id,
    required this.houseName,
    required this.ownerName,
    required this.ownerContact,
    required this.availableFlats,
    required this.latitude,
    required this.longitude,
    required this.rating,
  });

}