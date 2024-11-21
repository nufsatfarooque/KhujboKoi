import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khujbokoi/components/button.dart';
import 'package:khujbokoi/services/database.dart';
import 'package:intl/intl.dart'; // To format the timestamp
//import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeBoardScreen extends StatefulWidget {
  const NoticeBoardScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
 
   final TextEditingController textController = TextEditingController();
   final DatabaseService database = DatabaseService();

  //map for state of each button
  final Map<String, bool> isUpVotedMap = {};
  final Map<String, bool> isDownVotedMap = {};

  //
  final currentUser = FirebaseAuth.instance.currentUser;
 

 

  //upVote and DownVote button states
  bool isUpVoted = false;
  bool isDownVoted = false;

  void openPostBox({String? messageId}) async {
    var buttonText = "Post";

    // If a messageId is provided, fetch the existing message and pre-fill the TextField
    if (messageId != null) {
      buttonText = "Update";

      // Fetch the existing data from Firestore
      DocumentSnapshot document = await database.getMessageById(messageId);

      if (document.exists) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        String existingMessage = data['message'] ?? '';

        // Set the existing text in the text controller
        textController.text = existingMessage;
      }
    } else {
      // Clear the text controller if it's a new post
      textController.clear();
    }

    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          // Button to save or update the message
          ElevatedButton(
            onPressed: () {
              if (messageId == null) {
                buttonText = "Post";
                database.addMessage(textController.text);
              } else {
                buttonText = "Update";
                database.updateNote(messageId, textController.text);
              }
              // Clear the field
              textController.clear();
              // Close the dialog box
              Navigator.pop(context);
            },
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  void toggleUpVote(
      {messageId, required int currUpVotes, required int currDownVotes}) {
    setState(() {
      isUpVotedMap[messageId] =
          !(isUpVotedMap[messageId] ?? false); // Toggle upvote

      if (isUpVotedMap[messageId] == true) {
        //increment upVote and decrement downVote if it was on
        if (isDownVotedMap[messageId] == true && currDownVotes > 0) {
          database.updateVotes(messageId, DatabaseService.downVoteValDec,currentUser!);
        }
        isDownVotedMap[messageId] = false;
        database.updateVotes(messageId, DatabaseService.upVoteValInc,currentUser!);
      } else if (currUpVotes > 0) {
        database.updateVotes(messageId, DatabaseService.upVoteValDec,currentUser!);
      }
    });
  }

  void toggleDownVote(
      {messageId, required int currUpVotes, required int currDownVotes}) {
    setState(() {
      isDownVotedMap[messageId] = !(isDownVotedMap[messageId] ?? false);
      if (isDownVotedMap[messageId] == true) {
        if (isUpVotedMap[messageId] == true && currUpVotes > 0) {
          database.updateVotes(messageId, DatabaseService.upVoteValDec,currentUser!);
        }
        isUpVotedMap[messageId] = false;
        database.updateVotes(messageId, DatabaseService.downVoteValInc,currentUser!);
      } else if (currDownVotes > 0) {
        database.updateVotes(messageId, DatabaseService.downVoteValDec,currentUser!);
      }
    });
  }

@override
Widget build(BuildContext context) {
  return SafeArea(
    child: Scaffold(
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
        title: const Text('Khujbo Koi'),
        backgroundColor: Colors.transparent,
        actions: [
          const SizedBox(
            width: 50,
            height: 50,
            child: Icon(Icons.menu, color: Colors.green),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openPostBox,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<String>(
        future: database.getUserNamebyID(currentUser), // Fetch current user's name
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No user name available."));
          }

          final String currentUserName = snapshot.data!;

          return StreamBuilder<QuerySnapshot>(
            stream: database.getMessagesStream(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<DocumentSnapshot> messageList = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messageList.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = messageList[index];
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    
                    List<dynamic> dislikedBy = data['dislikedBy'] ?? [];
                    List<dynamic> likedBy = data['likedBy'] ?? [];
                    String messageId = document.id;
                    String messageTxt = data['message'] ?? 'No message';
                    String userName = data['userName'] ?? 'Anonymous';
                    Timestamp? timePosted = data['timePosted'] as Timestamp?;
                    int upVotes = data['upVotes'] ?? 0;
                    int downVotes = data['downVotes'] ?? 0;
                    
                    if(dislikedBy.contains(currentUser!.uid)){
                       isDownVotedMap[messageId] = true;}
                    else{
                      isDownVotedMap[messageId] = false;
                    }
                    if(likedBy.contains(currentUser!.uid)){
                       isUpVotedMap[messageId] = true;
                    }
                    else
                    {
                       isUpVotedMap[messageId] = false;
                    }
                    

                    // Format the timePosted
                    String formattedTime = timePosted != null
                        ? DateFormat.yMMMd().add_jm().format(timePosted.toDate())
                        : 'Unknown time';

                    // Check ownership
                    bool isMessageOwner = userName == currentUserName;

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                           Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Username and formatted time on the left
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        formattedTime,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Spacer to push buttons to the right side
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (userName == currentUserName)
                                        IconButton(
                                          onPressed: () => openPostBox(messageId: messageId),
                                          icon: const Icon(Icons.update_outlined),
                                        ),
                                      MyButton(
                                        messageId: messageId,
                                        currentUserName: currentUserName,
                                        msgUserName: userName,
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                            const SizedBox(height: 10),
                            Text(
                              messageTxt,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Column(
                                      children: [
                                        const Icon(Icons.thumb_up, size: 20),
                                        Text('$upVotes'),
                                      ],
                                    ),
                                    const SizedBox(width: 20),
                                    Column(
                                      children: [
                                        const Icon(Icons.thumb_down, size: 20),
                                        Text('$downVotes'),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => toggleUpVote(
                                          messageId: messageId,
                                          currDownVotes: downVotes,
                                          currUpVotes: upVotes),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isUpVotedMap[
                                                    messageId] ??
                                                false
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
                                      child: const Text("Upvote"),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () => toggleDownVote(
                                          messageId: messageId,
                                          currDownVotes: downVotes,
                                          currUpVotes: upVotes),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isDownVotedMap[
                                                    messageId] ??
                                                false
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                      child: const Text("Downvote"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const Text("No messages");
              }
            },
          );
        },
      ),
    ),
  );
}

}
