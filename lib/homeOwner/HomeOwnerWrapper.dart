// HomeOwnerWrapper.dart
import 'package:flutter/material.dart';
import 'package:khujbokoi/screen/home.dart';
import 'homeOwnerScreen.dart';
import 'SettingsScreen.dart';
import 'ViewReviewsScreen.dart';

class HomeOwnerWrapper extends StatefulWidget {
  final int initialIndex;
  const HomeOwnerWrapper({super.key, this.initialIndex = 0});

  @override
  _HomeOwnerWrapperState createState() => _HomeOwnerWrapperState();
}

class _HomeOwnerWrapperState extends State<HomeOwnerWrapper> {
  late int _selectedIndex;
  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  void onTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return const HomeOwnerScreen();
      case 1:
        return HomePage(
            onLoginPress: (){
              onTapped(2);   //navigate to loginscreen
            },
          );
      case 2:
        return const ViewReviewsScreen();
      case 3:
        return const SettingsScreen();
      default:
        return const HomeOwnerScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getSelectedScreen(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.reviews),
            label: 'Reviews', // Now third position
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings', // Now fourth position
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: onTapped,
      ),
    );
  }
}