import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khujbokoi/services/database.dart';

class SystemNoticeScreen extends StatefulWidget {
  const SystemNoticeScreen({super.key});

  @override
  State<SystemNoticeScreen> createState() => _SystemNoticeScreenState();
}

class _SystemNoticeScreenState extends State<SystemNoticeScreen> {
  final DatabaseService _database = DatabaseService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("System Notices"),
        backgroundColor: Colors.green,
      ),
      body: currentUser == null
          ? const Center(child: Text("No user logged in."))
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: _database.getUserNotices(currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No system notices."));
                }

                List<Map<String, dynamic>> notices = snapshot.data!;

                return ListView.builder(
                  itemCount: notices.length,
                  itemBuilder: (context, index) {
                    final notice = notices[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(
                          notice['title'] ?? "No Title",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notice['description'] ?? "No Description"),
                            const SizedBox(height: 4),
                            Text(
                              "Date: ${DateFormat.yMMMd().format((notice['timestamp'] as Timestamp).toDate())}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Mark as Read Button
                            IconButton(
                              icon: Icon(
                                Icons.check_circle,
                                color: notice['isRead'] == true
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              onPressed: () async {
                                if (notice['isRead'] == false) {
                                  await _database.markNoticeAsRead(
                                      currentUser!.uid, notice['id']);
                                  setState(() {}); // Refresh UI
                                }
                              },
                            ),
                            // Delete Button
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await _database.deleteNotice(
                                    currentUser!.uid, notice['id']);
                                setState(() {}); // Refresh UI
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
