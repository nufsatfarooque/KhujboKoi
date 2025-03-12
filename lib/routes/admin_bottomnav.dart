import 'package:flutter/material.dart';
import 'package:khujbokoi/screen/admin_home.dart';
import 'package:khujbokoi/screen/listing_approvals_panel.dart';
import 'package:khujbokoi/screen/manage_reports_page.dart';
import 'package:khujbokoi/screen/manage_users.dart';

class AdminBottomNav extends StatefulWidget {
  const AdminBottomNav({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminBottomNavState createState() => _AdminBottomNavState();
}

class _AdminBottomNavState extends State<AdminBottomNav> {
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
          AdminDashboard(
            onLoginPress: (){
              onTapped(2);   //navigate to loginscreen
            },
          ),
          ManageUsersPage(),
          ManageReportsPage(),
          ListingApprovalsPanel(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(
                Icons.bar_chart_outlined,
              ),
              label: 'Stats'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.supervised_user_circle_sharp,
              ),
              label: 'Manage Users'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.report_outlined,
              ),
              label: 'Manage Reports'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.approval,
              ),
              label: 'Approvals'),
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