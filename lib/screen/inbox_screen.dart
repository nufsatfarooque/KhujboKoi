import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InboxScreen extends StatefulWidget {
  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  Future<void> _getCurrentUserId() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchChats() async {
    Map<String, List<Map<String, dynamic>>> chatMap = {};

    if (currentUserId == null) {
      print("User is not logged in.");
      return chatMap;
    }

    try {
      QuerySnapshot chatSnapshot = await _firestore.collection('chats').get();
      print("Chat Snapshot Data: ${chatSnapshot.docs}");
      if (chatSnapshot.docs.isEmpty) {
        print("No chats found.");
        return chatMap;
      }

      for (var chatDoc in chatSnapshot.docs) {
        String chatId = chatDoc.id;

        

        if (!chatId.contains(currentUserId!)) continue;

        final messageSnapshot = await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .get();

        for (var message in messageSnapshot.docs) {
          final data = message.data();

          String otherUserId = data['senderId'] == currentUserId
              ? data['receiverId']
              : data['senderId'];

          chatMap.putIfAbsent(otherUserId, () => []).add({
            'content': data['content'],
            'timestamp': data['timestamp'],
            'chatId': chatId
          });
        }
      }
    } catch (e) {
      print("Error fetching chats: $e");
    }

    return chatMap;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder(
        future: fetchChats(),
        builder: (context, AsyncSnapshot<Map<String, List<Map<String, dynamic>>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No messages yet.'));
          }

          final chatMap = snapshot.data!;

          return ListView.builder(
            itemCount: chatMap.length,
            itemBuilder: (context, index) {
              String otherUserId = chatMap.keys.elementAt(index);
              List<Map<String, dynamic>> messages = chatMap[otherUserId]!;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text('Chat with: $otherUserId'),
                      subtitle: Text('${messages.first['content']}'),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: messages.length,
                      itemBuilder: (context, msgIndex) {
                        final msg = messages[msgIndex];

                        return ListTile(
                          title: Text(msg['content']),
                          subtitle: Text(msg['timestamp'].toDate().toString()),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
