import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeBoardScreen extends StatefulWidget {
  @override
  _NoticeBoardScreenState createState() => _NoticeBoardScreenState();
}

class _NoticeBoardScreenState extends State<NoticeBoardScreen> {
  // Simulated method for adding a notice (you can integrate Firebase)
  @override
  void initState() {
    super.initState();

    // Set the status bar color to green
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.green, // Status bar color
      ),
    );
  }
  void _addNotice() {
    // Add notice logic goes here
    print("Add Notice clicked");
  }

  // Function to toggle the like/dislike state
  bool isLiked = false;
  bool isDisliked = false;

  void _onLikeTapped() {
    setState(() {
      isLiked = !isLiked;
      if (isDisliked && isLiked) {
        isDisliked = false; // Reset dislike if like is selected
      }
    });
  }

  void _onDislikeTapped() {
    setState(() {
      isDisliked = !isDisliked;
      if (isLiked && isDisliked) {
        isLiked = false; // Reset like if dislike is selected
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
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
        title: const Text("KhujboKoi?", style: TextStyle(color: Colors.green)),
        backgroundColor: Colors.transparent,
        actions: [
          Container(
            width: 50,
            height: 50,
            child: const Icon(Icons.menu, color: Colors.green),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            // Add Notice Button
            ElevatedButton(
              onPressed: _addNotice,
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.all(10.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_circle_outline),
                  SizedBox(width: 8),
                  Text("Add Notice"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // List of Notices from Firebase
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('notices').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot notice = snapshot.data!.docs[index];
                      String name = notice['name'];
                      String status = notice['status'];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.green),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, color: Colors.black),
                            ),
                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(status, style: const TextStyle(fontSize: 14)),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                // Handle options
                              },
                              itemBuilder: (BuildContext context) {
                                return {'Edit', 'Delete'}.map((String choice) {
                                  return PopupMenuItem<String>(
                                    value: choice,
                                    child: Text(choice),
                                  );
                                }).toList();
                              },
                            ),
                            // Like and Dislike Row
                            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                            isThreeLine: true,
                            dense: true,
                            // Footer with like/dislike buttons
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(status),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.thumb_up,
                                          color: isLiked ? Colors.green : Colors.grey),
                                      onPressed: _onLikeTapped,
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.thumb_down,
                                          color: isDisliked ? Colors.red : Colors.grey),
                                      onPressed: _onDislikeTapped,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
