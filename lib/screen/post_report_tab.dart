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
            final report_id = report.id;

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
                                  width: MediaQuery.of(context).size.width *
                                      0.85, // 90% of screen width
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
                                        width: 35,
                                      ),
                                      // Status Text
                                      Text(
                                        'Status:$status',
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
                                  onPressed: () => {
                                    if(status == "pending")
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          AdminResponseToReporter(
                                        report_id: report_id,
                                        delete_post: true,
                                      ),
                                    )
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: status =="pending"?? false? 
                                                               Colors.redAccent:Colors.grey,
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
                                  onPressed: () => {
                                    if(status == "pending")
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          AdminResponseToReporter(
                                        report_id: report_id,
                                        delete_post: false,
                                      ),
                                    )
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: status == "pending" ?? false?
                                                                    Colors.orange:Colors.grey,
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

class AdminResponseToReporter extends StatelessWidget {
  AdminResponseToReporter({
    super.key,
    required this.report_id,
    required this.delete_post,
  });

  final TextEditingController _replyController = TextEditingController();

  final report_id;

  final bool delete_post;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Send a response to reporter",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _replyController,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: "Your response to the reporter",
                border: OutlineInputBorder(),
                hintText: "Describe why you took this action",
              ),
            )
          ],
        ),
      ),
      actions: [
        ElevatedButton(
            onPressed: () async {
              if (_replyController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Cannot give an empty response!"),
                ));
                return;
              }

              await DatabaseService().reportPost.doc(report_id).update({
                'response': _replyController.text,
                'status': "resolved",
              });
              
               // ignore: use_build_context_synchronously
              Navigator.pop(context);
              //init AdminResponseToAccused and pop this form
              if (delete_post) {
                showDialog(
                  // ignore: use_build_context_synchronously
                  context: context,
                  builder: (context) => AdminResponseToAccused(
                    report_id: report_id,
                
                  ),
                );
              }
             
            },
            child: Text("Send Response"))
      ],
    );
  }
}

class AdminResponseToAccused extends StatelessWidget {
  AdminResponseToAccused({super.key, required this.report_id});

  final TextEditingController _replyController = TextEditingController();

  final report_id;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Send a response to accused user",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _replyController,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: "Your response to the accused",
                border: OutlineInputBorder(),
                hintText: "Describe why you took this action",
              ),
            )
          ],
        ),
      ),
      actions: [
        ElevatedButton(
            onPressed: () async {
              if (_replyController.text == "") {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Cannot give an empty response!"),
                ));
                return;
              }

              await DatabaseService().reportPost.doc(report_id).update({
                'response_to_accused': _replyController.text,
              });

              //pop this response
              Navigator.pop(context);
            },
            child: Text("Send Response"))
      ],
    );
  }
}
