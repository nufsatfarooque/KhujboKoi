// HomeOwnerScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

import 'package:khujbokoi/screen/inbox_screen.dart';

class HomeOwnerScreen extends StatefulWidget {
  const HomeOwnerScreen({super.key});

  @override
  _HomeOwnerScreenState createState() => _HomeOwnerScreenState();
}

class _HomeOwnerScreenState extends State<HomeOwnerScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  String? _userName;
  String? _profilePictureBase64;
  File? _profileImage;
  double _averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.green,
      ),
    );
    _fetchUserData();
    _fetchAverageRating();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _userName = userDoc['name'] ?? "User";
          _profilePictureBase64 = userDoc['profilePictureBase64'];
        });
      }
    }
  }

  Future<void> _fetchAverageRating() async {
  User? user = _auth.currentUser;
  if (user != null) {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc['listings'] != null) {
        List<dynamic> listingIds = userDoc['listings'];
        double totalRating = 0.0;
        int count = 0;

        for (String listingId in listingIds) {
          DocumentSnapshot listingDoc = await _firestore.collection('listings').doc(listingId).get();
          if (listingDoc.exists) {
            var data = listingDoc.data() as Map<String, dynamic>;
            totalRating += data['rating'] ?? 0.0;
            count++;
          }
        }

        if (mounted) {
          setState(() {
            _averageRating = count > 0 ? totalRating / count : 0.0;
          });
        }
      }
      } catch (e) {
        print('Error fetching average rating: $e');
      }
    }
  }
  Future<void> _uploadProfilePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File imageFile = File(image.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      setState(() {
        _profileImage = imageFile;
        _profilePictureBase64 = base64Image;
      });

      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'profilePictureBase64': base64Image,
        });
      }
    }
  }

  Future<void> _logout() async {
    bool confirmLogout = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      await _auth.signOut();
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login_screen',
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7FE38D), Colors.white],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
            ),
          ),
          automaticallyImplyLeading: false,
          title: const Text(
            "KhujboKoi?",
            style: TextStyle(
              color: Colors.green,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.green, size: 30),
              onPressed: _logout,
            ),
          ],
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _uploadProfilePicture,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _profilePictureBase64 != null
                              ? MemoryImage(base64Decode(_profilePictureBase64!))
                              : const AssetImage('assets/defaultprofilepicture.jpg') as ImageProvider,
                          child: _profilePictureBase64 == null
                              ? const Icon(Icons.person, size: 50, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _userName ?? "User",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 24),
                          const SizedBox(width: 5),
                          Text(
                            _averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      TextButton(
                        onPressed: _uploadProfilePicture,
                        child: const Text(
                          "Change Profile Picture",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      // Removed Settings TextButton from here
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildActionCard(
                  icon: Icons.add_home_outlined,
                  title: "Add House",
                  subtitle: "List your property easily",
                  onPressed: () => Navigator.pushNamed(context, '/addhouse'),
                ),
                _buildActionCard(
                  icon: Icons.list_alt,
                  title: "View Listings",
                  subtitle: "Manage your listed properties",
                  onPressed: () => Navigator.pushNamed(context, '/viewListings'),
                ),
                _buildActionCard(
                  icon: Icons.house,
                  title: "View Rented Properties",
                  subtitle: "View your rented properties",
                  onPressed: () => Navigator.pushNamed(context, '/rentedProperties'),
                ),
                _buildActionCard(
                  icon: Icons.notifications_active,
                  title: "Latest Notices",
                  subtitle: "Stay updated with important notices",
                  onPressed: () => Navigator.pushNamed(context, '/notices'),
                ),
                _buildActionCard(
                  icon: Icons.message,
                  title: "Inbox",
                  subtitle: "View your chats with users",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InboxScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.green.shade800, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black45),
            ],
          ),
        ),
      ),
    );
  }
}