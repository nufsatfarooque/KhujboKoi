import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khujbokoi/services/database.dart';

class PostReportTab extends StatefulWidget {
  const PostReportTab({super.key});

  @override
  State<PostReportTab> createState() => _PostReportTabState();
}

final DatabaseService database = DatabaseService();

class _PostReportTabState extends State<PostReportTab> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: database.getPostReportStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No reports found.'));
        }

        final reports = snapshot.data!.docs;

        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            final reportedBy = report['reported_by'];
            final reportedPostId = report['reported_post_id'];
            final type = report['type'];
            final timeReported = DateFormat.yMMMd()
                .add_jm()
                .format(report['time_reported'].toDate());
            final status = report['status'];
            final comment = report['comment'];

            return FutureBuilder<DocumentSnapshot>(
              future: database.getMessageById(reportedPostId),
              builder: (context, messageSnapshot) {
                if (!messageSnapshot.hasData) {
                  return const SizedBox(); // Avoid building incomplete cards
                }

                final messageData = messageSnapshot.data!;
                final messageText = messageData['message'];
                final userName = messageData['userName'];
                final timePosted = DateFormat.yMMMd()
                    .add_jm()
                    .format(messageData['timePosted'].toDate());

                final upVotes = messageData['upVotes'];
                final downVotes = messageData['downVotes'];

                return FutureBuilder<QuerySnapshot>(
                  future: database.getUserbyUserName(reportedBy),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData ||
                        userSnapshot.data!.docs.isEmpty) {
                      return const SizedBox(); // Avoid building incomplete cards
                    }

                    final userData = userSnapshot.data!.docs.first;
                    final userRole = userData['role'];

                    return Card(
                      elevation: 5,
                      color: const Color.fromARGB(255, 223, 252, 229),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.orange,
                                        child: Text(
                                          userData['name'][0].toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            userData['name'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            userRole,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          Text(
                                            'Reported @: $timeReported',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 37,
                                      ),
                                      // Status Text
                                      Text(
                                        'Status: $status',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Divider(color: Colors.grey.shade300),
                            const SizedBox(height: 4),
                            Text(
                              'Type: $type',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: TextEditingController()
                                ..text = comment,
                              readOnly: true,
                              maxLines: null,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.green,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.blue,
                                    width: 1.5,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              style: const TextStyle(fontSize: 14),
                            ),
                            // const SizedBox(height: 8),
                            Divider(color: Colors.grey.shade300),
                            // const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(
                                  8.0), // Padding inside the border
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.shade400,
                                    width: 1), // Border color and width
                                borderRadius: BorderRadius.circular(
                                    12), // Rounded corners
                                color: const Color.fromARGB(255, 223, 252, 229),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'User: $userName',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Posted @: $timePosted',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "$messageText",
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.thumb_up_alt_outlined,
                                          size: 16, color: Colors.green),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$upVotes',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(Icons.thumb_down_alt_outlined,
                                          size: 16, color: Colors.red),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$downVotes',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // will be implemented later
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      shadowColor: Colors.black,
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      )),
                                  child: const Text(
                                    'Delete Post',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 7,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // will be implemented later
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      shadowColor: Colors.black,
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      )),
                                  child: const Text(
                                    '   Ignore   ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
