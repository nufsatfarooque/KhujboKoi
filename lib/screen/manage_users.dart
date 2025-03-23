//import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khujbokoi/routes/app_routes.dart';
import 'package:khujbokoi/screen/onboarding_screen.dart';
import 'package:khujbokoi/services/database.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

final DatabaseService database = DatabaseService();

class _ManageUsersPageState extends State<ManageUsersPage> {

   // Map storing GlobalKeys for each user UID
final Map<String, GlobalKey> _userCardKeys = {};

//Retrieve or create key for a user UID
GlobalKey _getKey(String userName){
  if (!_userCardKeys.containsKey(userName)){
    _userCardKeys[userName] = GlobalKey();
  }
  return _userCardKeys[userName]!;
}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if a targetUID was passed via the route arguments
    final targetUID = ModalRoute.of(context)?.settings.arguments as String?;
    if (targetUID != null) {
      // Use a post frame callback to ensure the widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final targetKey = _userCardKeys[targetUID];
        if (targetKey != null && targetKey.currentContext != null) {
          Scrollable.ensureVisible(
            targetKey.currentContext!,
            duration: const Duration(seconds: 1),
          );
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.pushNamed(context, AppRoutes.adminNav);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.green),) ,
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
                    builder: (context) => OnboardingScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
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
              final userBanned = userData?.containsKey('banned') == true
                  ? userData!['banned']
                  : false;
              final bannedTill = userData?.containsKey('banned_till') == true
                  ? DateFormat.yMMMd()
                      .add_jm()
                      .format(userData!['banned_till'].toDate())
                  : "Not Banned";

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
                  if(userRole == 'Administrator')
                  {
                     return const SizedBox();
                  }
                  return Card(
                    key: _getKey(userName), //assign global key
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
                                  if (userBanned)
                                    Text(
                                      'Banned till: $bannedTill',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  if (!userBanned)
                                    Text(
                                      'Not Banned',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
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
                                onPressed: userBanned ? null : () => {
                                  _showBanUserDialog(context, user.id, userName),
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  shadowColor: Colors.black,
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                                child: Text(
                                  userBanned ? "User Banned" : "Ban User",
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
                                  onPressed: userBanned ? null : () => {
                                    _disableAccount(user.id, userName),
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      shadowColor: Colors.black,
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      )),
                                  child: Text(
                                    userBanned ? "Cannot Disable" : "Disable Account",
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
      ),
    );
  }
}

void _showBanUserDialog(BuildContext context,String uid ,String userName) {
  int selectedDays = 1;
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Ban User: $userName"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Select ban duration (in days):"),
                const SizedBox(height: 8),
                DropdownButton<int>(
                  value: selectedDays,
                  items: [1, 3, 7, 14, 30].map((int days) {
                    return DropdownMenuItem<int>(
                      value: days,
                      child: Text("$days day${days > 1 ? 's' : ''}"),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedDays = newValue!;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // cancel action
                },
                child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Call your ban user method here with the selectedDays
                  // For example: database.banUser(userName, selectedDays);
                  await DatabaseService().userInfo.doc(uid).update({
                    'banned': true,
                    'banned_till': Timestamp.now().toDate().add(Duration(days: selectedDays)),
                  });
                  if (kDebugMode) {
                    print("Disabling user $userName with uid $uid for  $selectedDays days");
                  }

                  Navigator.pop(context);
                },
                child: const Text("Ban User"),
              ),
            ],
          );
        },
      );
    },
  );
}

void _disableAccount(String uid, String userName) async {
  // Call your disable account method here
  // For example: database.disableAccount(userName);
  if (kDebugMode) {
    print("Disabling account for user $userName with uid $uid");
  }
    await DatabaseService().userInfo.doc(uid).update({
                    'banned': true,
                    'banned_till': Timestamp.now().toDate().add(Duration(days: 3650)),
                  });
}