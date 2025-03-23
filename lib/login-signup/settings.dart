import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khujbokoi/screen/onboarding_screen.dart';
import 'package:khujbokoi/login-signup/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    // Set the status bar color to green
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.green, // Status bar color
      ),
    );
  }

  Future<void> _fetchUserData() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = 
          await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        setState(() {
          _userName = userDoc['name'] ?? 'User'; // Default to 'User' if no name exists
        });
      }
    } catch (e) {
      print("Failed to load user data: $e");
    }
  }

  final Map<String, Widget Function()> _routes = {
    //'Become a House Owner': ()=> HouseOwner(), //route to go to that page of the tile, notification ba language e click korle ei function gula call hbe
  };

  void _navigateTo(String title) {
    if (_routes.containsKey(title)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SettingsPage(),
        ),
      );
    } else {
      print("No route created yet for $title");
    }
  }

  ListTile _buildListItem(String title) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () => _navigateTo(title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[Color(0xFF7FE38D), Colors.white],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
            ),
          ),
          automaticallyImplyLeading: false,
          title:
              const Text("KhujboKoi?", style: TextStyle(color: Colors.green)),
          backgroundColor: Colors.transparent,
          actions: [
            SizedBox(
              width: 50,
              height: 50,
              child: const Icon(Icons.menu, color: Colors.green),
            ),
          ],
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(35.0),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://via.placeholder.com/150'), // Use a placeholder image URL
                  radius: 30,
                ),
                title: Text(
                  _userName, // Display the user's name here
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: const Text("Edit Profile"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfilePage()),
                  );
                },
              ),
            ),
            const Divider(),
            _buildListItem('Become a House Owner'),
            _buildListItem('See Past Reviews'),
            _buildListItem('Favourites'),
            const Divider(),
            _buildListItem('Notifications'),
            _buildListItem('See Marked Notices'),
            _buildListItem('Language'),
            const Divider(),
            _buildListItem('Clear cache'),
            _buildListItem('Terms & Privacy Policy'),
            _buildListItem('Contact us'),
            TextButton(
              onPressed: () {
                // Log out function can be implemented here
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => OnboardingScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text(
                'Log out',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
