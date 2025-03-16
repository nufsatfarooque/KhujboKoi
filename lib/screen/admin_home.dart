import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:async/async.dart'; // Import the rxdart package
import 'package:khujbokoi/screen/login_screen.dart';
import 'package:khujbokoi/services/database.dart';
import 'package:khujbokoi/components/line_chart_widget.dart';

class AdminDashboard extends StatefulWidget {
  final VoidCallback onLoginPress;
  const AdminDashboard({super.key, required this.onLoginPress});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final DatabaseService database = DatabaseService();

  @override
  void initState() {
    super.initState();
   // database.addProcessedFieldToListings();
    // Set the status bar color to green
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.green, // Status bar color
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
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
        title: const Text("KhujboKoi?", style: TextStyle(color: Colors.green)),
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
      ),
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
                // Active Users Line Graph
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
                      child: StreamBuilder<Map<String, int>>(
                        stream: database.getActiveUsersWeeklyReport(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          return LineChartWidget(
                            data: snapshot.data!,
                            chartTitle: "Weekly User Sign-ins",
                            colorPreset: 0,
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Approvals Pending and Reports Made
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        // Approvals Pending
                        Expanded(
                            child: FutureBuilder<int>(
                          future: database.countPendingApprovals(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return StatBox(
                                label: "Approvals pending",
                                value:
                                    "...", // Show a placeholder while loading
                              );
                            }
                            if (snapshot.hasError) {
                              return StatBox(
                                label: "Approvals pending",
                                value: "Error",
                              );
                            }
                            return StatBox(
                              label: "Approvals pending",
                              value: snapshot.data?.toString() ??
                                  "0", // Display count or 0 if null
                            );
                          },
                        )),
                        const SizedBox(width: 8.0), // Horizontal spacing

                        // Reports Made with Pie Chart
                        Expanded(
                          child: Container(
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
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(16.0),
                            child: StreamBuilder<List<int>>(
                              stream: StreamZip([
                                database.countUserReportsToday(),
                                database.countPostReportsToday(),
                              ]),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const CircularProgressIndicator();
                                }

                                final userReports = snapshot.data![0];
                                final postReports = snapshot.data![1];

                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Reports made : ${userReports + postReports}",
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16.0),

                                    // Pie Chart for Reports
                                    Flexible(
                                      child: PieChart(
                                        PieChartData(
                                          sections: [
                                            PieChartSectionData(
                                              value: userReports.toDouble(),
                                              color: const Color.fromARGB(
                                                  251, 82, 147, 127),
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
                                              color: const Color.fromARGB(
                                                  255, 232, 156, 93),
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
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Weekly Post Activity Graph
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
                      child: StreamBuilder<Map<String, int>>(
                        stream: database.getPostsWeeklyReport(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          return LineChartWidget(
                            data: snapshot.data!,
                            chartTitle: "Weekly Posts Activity",
                            colorPreset: 1,
                          );
                        },
                      ),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 66.0,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange, // Dark green color
              shadows: [
                Shadow(
                  color: Colors.black38, // Shadow color
                  blurRadius: 0.5, // How soft the shadow is
                  offset: Offset(2, 2), // Offset from the text
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
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
