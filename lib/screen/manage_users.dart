
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khujbokoi/services/database.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

final DatabaseService database = DatabaseService();

class _ManageUsersPageState extends State<ManageUsersPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: database.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No reports found.'));
        }

        final users = snapshot.data!.docs;

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final userData =
                user.data() as Map<String, dynamic>?; // Convert to map safely
            final userName = user['name'];
            final lastSignIn = DateFormat.yMMMd()
                .add_jm()
                .format(user['last_signed_in'].toDate());
            final userEmail = userData?.containsKey('email') == true
                ? userData!['email']
                : "Not Available";

            final userPhnNum = userData?.containsKey('phoneNumber') == true
                ? userData!['phoneNumber']
                : "Not Available";

            final dateCreated = DateFormat.yMMMd()
                .add_jm()
                .format(user['date_created'].toDate());
            return FutureBuilder<QuerySnapshot>(
              future: database.getUserbyUserName(userName),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
                  return const SizedBox(); // Avoid building incomplete cards
                }

                final userData = userSnapshot.data!.docs.first;
                final userRole = userData['role'];

                return Card(
                  elevation: 5,
                  color: const Color.fromARGB(255, 223, 252, 229),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Center(
                                    child: Column(
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
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        Text(
                                          'Last Sign in @: $lastSignIn',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Status Text
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(
                              8.0), // Padding inside the border
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey.shade400,
                                width: 1), // Border color and width
                            borderRadius:
                                BorderRadius.circular(12), // Rounded corners
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Account created: $dateCreated',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Email: $userEmail',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Phone number: $userPhnNum',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              onPressed: () => {},
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  shadowColor: Colors.black,
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                              child: Text("Delete Account",
                               style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),),
                            ),
                            SizedBox(
                              width: 7,
                            ),
                            ElevatedButton(
                                onPressed: () => {},
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    shadowColor: Colors.black,
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    )),
                                child: Text("Ban User",
                                 style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),))
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
