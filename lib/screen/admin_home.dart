import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khujbokoi/services/database.dart';
import 'package:khujbokoi/components/line_chart_widget.dart';
class AdminDashboard extends StatefulWidget {
  final VoidCallback onLoginPress;
  const AdminDashboard({super.key, required this.onLoginPress});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int userReports = 0; // To store user reports count
  int postReports = 0; // To store post reports count
  Map<String, int> weeklyPostsCount = {};
  final DatabaseService database = DatabaseService();

  @override
  void initState() {
    super.initState();

    // Set the status bar color to green
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.green, // Status bar color
      ),
    );

    // Fetch reports data
    fetchReportsData();
    // Fetch weekly posts number
    fetchWeeklyPostsCount();
  }

  Future<void> fetchWeeklyPostsCount() async {
    Map<String, int> weeklyReport = await database.getPostsWeeklyReport();

    setState(() {
      weeklyPostsCount = weeklyReport;
    });
  }

  Future<void> fetchReportsData() async {
    int userReportsCount = await database.countUserReportsToday();
    int postReportsCount = await database.countPostReportsToday();

    setState(() {
      userReports = userReportsCount;
      postReports = postReportsCount;
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          width: double.infinity,
          color: Colors.green,
          padding: const EdgeInsets.all(16.0),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "KhujboKoi?",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                "Welcome Admin",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Dashboard Content
        Expanded(
          child: Column(
            children: [
              // Active Users Line Graph Placeholder
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PlaceholderBox(
                    text: "Active users line graph",
                  ),
                ),
              ),

              // Vertical Spacing
              //const SizedBox(height: 1.0),

              // Approvals Pending and Reports Made Row
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // Approvals Pending
                      Expanded(
                        child: StatBox(
                          label: "Approvals pending",
                          value: "12", // Placeholder value
                        ),
                      ),

                      const SizedBox(width: 8.0), // Horizontal spacing

                      // Reports Made with Pie Chart
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Reports Label
                              Text(
                                "Reports made : ${userReports + postReports}",
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16.0), // Spacing before pie chart

                              // Pie Chart for Reports
                              if (userReports + postReports > 0)
                                Flexible(
                                  child: PieChart(
                                    PieChartData(
                                      sections: [
                                        PieChartSectionData(
                                          value: userReports.toDouble(),
                                          color: const Color.fromARGB(251, 82, 147, 127),
                                          title:
                                              "Users: ${((userReports / (userReports + postReports)) * 100).toStringAsFixed(1)}%",
                                          radius: 52,
                                          titleStyle: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        PieChartSectionData(
                                          value: postReports.toDouble(),
                                          color: const Color.fromARGB(255, 243, 165, 101),
                                          title:
                                              "Posts: ${((postReports / (userReports + postReports)) * 100).toStringAsFixed(1)}%",
                                          radius: 52,
                                          titleStyle: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 45,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Vertical Spacing
              //const SizedBox(height: 1.0),

              // Post Activity Graph Placeholder
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: Colors.green.shade400,
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8.0,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10.0),
                    child:LineChartWidget(data: weeklyPostsCount,chartTitle: "Weekly Posts Activity",),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}


class PlaceholderBox extends StatelessWidget {
  final String text;

  const PlaceholderBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12.0),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class StatBox extends StatelessWidget {
  final String label;
  final String value;

  const StatBox({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12.0),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 36.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class GlassContainer extends StatelessWidget {
  final Widget child;

  const GlassContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.shade400
            .withOpacity(0.3), // Semi-transparent background
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.green.shade400.withOpacity(0.2), // Subtle border color
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Blur effect
          child: child,
        ),
      ),
    );
  }
}
