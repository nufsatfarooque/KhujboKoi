import 'package:flutter/material.dart';
import 'package:khujbokoi/screen/post_report_tab.dart';

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
      child: SafeArea(
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
              const SizedBox(
                width: 50,
                height: 50,
                child: Icon(Icons.menu, color: Colors.green),
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
                child: Text("User Reports go here"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
