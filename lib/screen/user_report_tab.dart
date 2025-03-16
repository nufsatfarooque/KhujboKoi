import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khujbokoi/routes/app_routes.dart';
import 'package:khujbokoi/services/database.dart';

class UserReportTab extends StatefulWidget {
  const UserReportTab({super.key});

  @override
  State<UserReportTab> createState() => _UserReportTabState();
}

final DatabaseService database = DatabaseService();

class _UserReportTabState extends State<UserReportTab> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: database.getUserReportStream(),
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
            final reportedUser = report['reported_id'];
            final type = report['type'];
            final timeReported = DateFormat.yMMMd()
                .add_jm()
                .format(report['time_reported'].toDate());
          
            final comment = report['comment'];
            final report_id = report.id;
            final reportData = report.data() as Map<String, dynamic>;
            final status = reportData.containsKey('status')
                ? reportData['status']
                : 'pending';
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
                                    'User: $reportedUser',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  
                                  const SizedBox(height: 8),
                                 
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ElevatedButton(
                                  onPressed: () async => {
                                    if (status == "pending"){
                                      await DatabaseService().reportUser.doc(report_id).update({
                                        'status': "resolved",
                                      }),
                                      Navigator.pushNamed(
                                        context, 
                                        AppRoutes.manageUsersRoute,
                                        arguments:reportedUser,
                                        )
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          status == "pending" ?? false
                                              ? Colors.redAccent
                                              : Colors.grey,
                                      shadowColor: Colors.black,
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      )),
                                  child: const Text(
                                    'Take Action',
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
                                    if (status == "pending")
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            AdminResponseToReporter(
                                          report: report,
                                          delete_post: false,
                                        ),
                                      )
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          status == "pending" ?? false
                                              ? Colors.orange
                                              : Colors.grey,
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
  }
}

class AdminResponseToReporter extends StatelessWidget {
  AdminResponseToReporter({
    super.key,
    required this.report,
    required this.delete_post,
  });

  final TextEditingController _replyController = TextEditingController();

  final report;

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

              await DatabaseService().reportUser.doc(report.id).update({
                'response': _replyController.text,
                'status': "resolved",
              });

              String reporter_uid = await DatabaseService()
                  .getUIDbyUserName(report['reported_by']);

              database.addNoticeForUser(reporter_uid, {
                'title': 'Our response to your report ${report['comment']}',
                'description': _replyController.text,
                'timestamp': Timestamp.now(),
                'isRead': false,
              });

              // ignore: use_build_context_synchronously
              Navigator.pop(context);
              //init AdminResponseToAccused and pop this form
             
            },
            child: Text("Send Response"))
      ],
    );
  }
}

class AdminResponseToAccused extends StatelessWidget {
  AdminResponseToAccused({super.key, required this.report});

  final TextEditingController _replyController = TextEditingController();

  final report;
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

              await DatabaseService().reportPost.doc(report.id).update({
                'response_to_accused': _replyController.text,
              });

              // Extract post owner's UID

              // Fetch the message document
              DocumentSnapshot messageSnapshot =
                  await database.getMessageById(report['reported_post_id']);
              Map<String, dynamic> messageData =
                  messageSnapshot.data() as Map<String, dynamic>;
              String? msgUserUID =
                  await database.getUIDbyUserName(messageData['userName']);
              await database.addNoticeForUser(msgUserUID, {
                'title':
                'Your post "${messageData['message']}" has been removed',
                'description': _replyController.text,
                'timestamp': Timestamp.now(),
                'isRead': false,
              });
 
              await DatabaseService().messages.doc(report['reported_post_id'])
              .update({
                'archive': true,
              });
              // Ensure the document exists

              //pop this response
              Navigator.pop(context);
            },
            child: Text("Send Response"))
      ],
    );
  }
}
