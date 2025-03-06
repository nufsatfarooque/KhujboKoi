// import 'dart:ffi';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'dart:convert';
// import 'package:khujbokoi/chat%20screen/chatScreen.dart';

// class HouseDetailsPage extends StatefulWidget {
//   final String houseId;
//   final double userLatitude;
//   final double userLongitude;
  
//   const HouseDetailsPage({
//     super.key,
//     required this.houseId,
//     required this.userLatitude,
//     required this.userLongitude,
//   });

//   @override
//   State<HouseDetailsPage> createState() => _HouseDetailsPageState();
// }

// class _HouseDetailsPageState extends State<HouseDetailsPage> {
//   Map<String, dynamic> houseDetails = {};
//   double distance = 0.0;
//   LatLng position = LatLng(0.0, 0.0);

//   @override
//   void initState() {
//     super.initState();
//     getHouseDetails();
//   }

//   Future<void> getHouseDetails() async {
//     try {
//       DocumentSnapshot house = await FirebaseFirestore.instance
//           .collection('listings')
//           .doc(widget.houseId)
//           .get();

//       if (!house.exists) return;

//       setState(() {
//         houseDetails = house.data() as Map<String, dynamic>;
//         var address = houseDetails['addressonmap'];

//         if (address is GeoPoint) {
//           position = LatLng(address.latitude, address.longitude);
//         } else if (address is Map<String, dynamic>) {
//           position = LatLng(address['latitude'], address['longitude']);
//         }

//         distance = Geolocator.distanceBetween(
//                 widget.userLatitude,
//                 widget.userLongitude,
//                 position.latitude,
//                 position.longitude) /
//             1000;
//       });
//     } catch (e) {
//       print('Error fetching house details: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (houseDetails.isEmpty) {
//       return Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: <Color>[Color(0xFF7FE38D), Colors.white],
//               begin: Alignment.centerRight,
//               end: Alignment.centerLeft,
//             ),
//           ),
//         ),
//         title: const Text("KhujboKoi?", style: TextStyle(color: Colors.green)),
//         backgroundColor: Colors.transparent,
//         actions: const [
//           SizedBox(
//             width: 50,
//             height: 50,
//             child: Icon(Icons.menu, color: Colors.green),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         physics: BouncingScrollPhysics(),
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (houseDetails['images'] != null && houseDetails['images'] is List && (houseDetails['images'] as List).isNotEmpty)
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: SizedBox(
//                     height: 250,
//                     width: double.infinity,
//                     child: PageView.builder(
//                       itemCount: (houseDetails['images'] as List).length,
//                       itemBuilder: (context, index) {
//                         return Image.memory(
//                           base64Decode((houseDetails['images'] as List)[index]),
//                           fit: BoxFit.cover,
//                           width: double.infinity,
//                           errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 100, color: Colors.grey),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               SizedBox(height: 16),
//               _buildInfoCard(Icons.home, "Name", houseDetails['buildingName'] ?? "No name"),
//               _buildInfoRow([
//                 _buildInfoCard(Icons.category, "Type", houseDetails['type'] ?? "N/A"),
//                 _buildInfoCard(Icons.star, "Rating", houseDetails['rating']?.toString() ?? "N/A"),
//               ]),
//               _buildInfoRow([
//                 _buildInfoCard(Icons.bed, "Bedrooms", houseDetails['bedrooms']?.toString() ?? "N/A"),
//                 _buildInfoCard(Icons.bathtub, "Bathrooms", houseDetails['bathrooms']?.toString() ?? "N/A"),
//               ]),
//               _buildInfoCard(Icons.attach_money, "Rent", "${houseDetails['rent'] ?? 'N/A'} BDT"),
//               _buildInfoCard(Icons.location_on, "Address", houseDetails['address'] ?? "N/A"),
//               _buildInfoCard(Icons.description, "Description", houseDetails['description'] ?? "No description"),
//               _buildInfoCard(Icons.directions_walk, "Distance", "${distance.toStringAsFixed(2)} km"),
//               SizedBox(height: 16),
//               SizedBox(
//                 height: 250,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: GoogleMap(
//                     initialCameraPosition: CameraPosition(target: position, zoom: 14),
//                     markers: {
//                       Marker(markerId: MarkerId('house'), position: position, infoWindow: InfoWindow(title: houseDetails['buildingName'])),
//                       Marker(markerId: MarkerId('user'), position: LatLng(widget.userLatitude, widget.userLongitude), infoWindow: InfoWindow(title: 'Your Location'), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose)),
//                     },
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 height: 55,
//                 child: ElevatedButton.icon(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                   ),
//                   onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Chatscreen())),
//                   icon: Icon(Icons.chat),
//                   label: Text("Chat with Owner", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 ),
//               ),
//               SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoCard(IconData icon, String title, String value) {
//     return Card(
//       margin: EdgeInsets.symmetric(vertical: 6),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       elevation: 3,
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Icon(icon, color: Colors.green, size: 20),
//             SizedBox(width: 10),
//             Expanded(
//               child: RichText(
//                 text: TextSpan(
//                   style: TextStyle(fontSize: 16, color: Colors.black),
//                   children: [
//                     TextSpan(
//                       text: "$title: ",
//                       style: TextStyle(fontWeight: FontWeight.w500),
//                     ),
//                     TextSpan(text: value),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
        
//       ),
//     );
//   }

//   Widget _buildInfoRow(List<Widget> children) {
    
//     return Row(
//       children: children.expand((e) => [Expanded(child: e), SizedBox(width: 10)]).toList()..removeLast(),
//     );
//   }
// }
