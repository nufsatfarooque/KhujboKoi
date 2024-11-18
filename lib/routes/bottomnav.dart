import 'package:flutter/material.dart';
import 'package:khujbokoi/screen/reviews.dart';
import '../screen/notice.dart';
import '../screen/sign_up_screen.dart';
import '../screen/home.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int selectedindex = 0;
  PageController pageController = PageController();

  // List<Widget> widgets = [
  //   Text('Home'),
  //   Text('Search'),
  //   Text('Add'),
  //   Text('Profile'),
  // ];
  void onTapped(int index) {
    setState(() {
      selectedindex = index;
    });
    pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Bottom Nav')),
      body: PageView(
        controller: pageController,
        onPageChanged: (index){
          setState(() {
            selectedindex = index;
          });
        },
        children: [
          HomePage(
            onLoginPress: (){
              onTapped(2);   //navigate to loginscreen
            },
          ),
          ReviewsPage(),
          NoticeBoardScreen(),
          SignUpScreen()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: 'House'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.star,
              ),
              label: 'Reviews'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.notifications,
              ),
              label: 'Notice'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
              ),
              label: 'Profile'),
        ],
        currentIndex: selectedindex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: onTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}