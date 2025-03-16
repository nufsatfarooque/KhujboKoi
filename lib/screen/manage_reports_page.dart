import 'package:flutter/material.dart';
import 'package:khujbokoi/screen/login_screen.dart';
import 'package:khujbokoi/screen/post_report_tab.dart';
import 'package:khujbokoi/screen/user_report_tab.dart';

class ManageReportsPage extends StatefulWidget {
  const ManageReportsPage({super.key});

  @override
  State<ManageReportsPage> createState() => _ManageReportsPageState();
}

class _ManageReportsPageState extends State<ManageReportsPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
     
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
            title: const Text(
              "KhujboKoi?",
              style: TextStyle(color: Colors.green),
            ),
            backgroundColor: Colors.transparent,
            actions: [
             IconButton(
              icon: const Icon(Icons.logout, color: Colors.green),
              onPressed: () {
                // Define the action to be performed when the button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              },
            ),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(
                  text: "Post Reports",
                  
                ),
                Tab(
                  text: "User Reports",
                ),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              Center(
                child: PostReportTab(),
              ),
              Center(
                child: UserReportTab(),
              ),
            ],
          ),
        ),

    );
  }
}
