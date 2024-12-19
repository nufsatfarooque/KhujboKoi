import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

class DatabaseService{
  //get collection of
  static const int downVoteValDec = -1; 
  static const int downVoteValInc = 0;
  static const int upVoteValInc = 1;
  static const int upVoteValDec = 2;

  final CollectionReference messages = 
       FirebaseFirestore.instance.collection('messages');
  final CollectionReference reportPost = 
       FirebaseFirestore.instance.collection('report_post');
  final CollectionReference reportUser = 
       FirebaseFirestore.instance.collection('report_user');
  final currentUser = FirebaseAuth.instance.currentUser;
  final CollectionReference userInfo = 
      FirebaseFirestore.instance.collection('users'); //relates email to username
  final dailySignIns = 
        FirebaseFirestore.instance.collection('daily_sign_ins');
   
  //Create
   Future<void> addMessage(String note) async {
  try {
    // Fetch the userName asynchronously
    final userName = await getUserNamebyID(currentUser);

    // Add the message to the database
    await FirebaseFirestore.instance.collection('messages').add({
      'message': note,
      'timePosted': Timestamp.now(),
      'downVotes': 0,
      'upVotes': 0,
      'userName': userName,
      "likedBy": [], // List of user IDs who liked
      "dislikedBy": [] // List of user IDs who disliked
    });
  } catch (e) {
    throw Exception('Failed to add message');
  }
}
  //Read
   Stream<QuerySnapshot> getMessagesStream(){
    final messagesStream = 
      messages.orderBy('timePosted',descending: true).snapshots();

    return messagesStream;
   }
  //Update
   Future<void> updateNote(String messageId,String newNote){
    return messages.doc(messageId).update({
      'message': newNote,
      'timePosted' : Timestamp.now()
    });
   }

  void handleLikeDislike (String messageId,bool islike,User? currentUser) async {
    final user = currentUser;
    if(user == null)
    {
      throw Exception("no valid user found");
    }

    final userID = user.uid; //userID may be null

    if(kDebugMode){
      print("UserID: $userID");
    }

    final messageDoc = FirebaseFirestore.instance.collection('messages').doc(messageId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(messageDoc);
        if(!snapshot.exists)
        {
          throw Exception("Message don't exist");
        }

        final data = snapshot.data() as Map<String,dynamic>;
        List<dynamic> likedBy = data['likedBy']??[]; //can be null,if null set as empty
        List<dynamic> dislikedBy = data['dislikedBy']??[];

        //if like button was pressed
        if(islike){
           if(likedBy.contains(userID)){
            //user already liked it, so remove him from list
            likedBy.remove(userID);
           }
           else
           {
            likedBy.add(userID);
            dislikedBy.remove(userID);
           }
        }
        //if dislike button was pressed
        else{
           if(dislikedBy.contains(userID)){
            dislikedBy.remove(userID);
           }
           else
           {
            dislikedBy.add(userID);
            likedBy.remove(userID);
           }
        }

        transaction.update(messageDoc, {
            'likedBy': likedBy,
            'dislikedBy': dislikedBy,
           
        });
    });
    
  }

  //Update votes 
  Future<void> updateVotes(String messageId,int type,User? currentUser)
  {
    if(type == downVoteValInc) {
      handleLikeDislike(messageId,false,currentUser);
    return messages.doc(messageId).update({
      'downVotes': FieldValue.increment(1),
    });
    
    }
    else if(type == downVoteValDec){
      handleLikeDislike(messageId,false,currentUser);
      return messages.doc(messageId).update(
        {
          'downVotes' : FieldValue.increment(-1),
        }
      );
    }
    else if(type == upVoteValInc)
    {
       handleLikeDislike(messageId,true,currentUser);
      return messages.doc(messageId).update(
         {
          'upVotes' : FieldValue.increment(1),
         }
      );
    }
    else if (type == upVoteValDec)
    {
       handleLikeDislike(messageId,true,currentUser);
      return messages.doc(messageId).update(
        {
          'upVotes' : FieldValue.increment(-1),
        }
      );
    }

    throw ArgumentError("Vote type unrecognised  : $type");
  }

  // Method to get a specific message by its ID
  Future<DocumentSnapshot> getMessageById(String messageId) {
    return messages.doc(messageId).get();
  }

  
  //Delete

  Future<void> deleteMessage(String messageId)async {
    return messages.doc(messageId).delete().then((_){
       
    }).catchError((error){
       if (kDebugMode) {
         print("Failed to delete message: $error");
       }
    });
     
    
  }

  Future<void> addPostReport(String comment,String reportedBy,String messageId,String type)
   {
    return reportPost.add({
       'comment' : comment,
       'reported_by' : reportedBy,
       'reported_post_id' : messageId,
       'time_reported' : Timestamp.now(),
       'type' : type,
       'status' : "pending",
    });
  }

    Future<void> addUserReport(String comment,String reportedBy,String reportedUser,String type)
   {
    return reportUser.add({
       'comment' : comment,
       'reported_by' : reportedBy,
       'reported_id' : reportedUser,
       'time_reported' : Timestamp.now(),
       'type' : type,
       'status' : "pending",
    });
  }

  Stream<QuerySnapshot> getPostReportStream(){
     final postReportStream = 
      reportPost.orderBy('time_reported',descending: true).snapshots();

    return postReportStream;
  }

  Stream<QuerySnapshot> getUserReportStream(){
    final userReportStream = 
     reportUser.orderBy('time_reported',descending: true).snapshots();

    return userReportStream;
  }

  //return username given an email
  Future<String> getUserNamebyID(User? curUser) async{
    try{
        DocumentSnapshot document = await userInfo.doc(curUser!.uid).get();
        //if document exists
        if(document.exists && document.data() != null)
        {
          Map<String,dynamic> data = document.data() as Map<String,dynamic>;
          return data['name'] ?? 'undefined';
        }
        else{
          
          throw Exception('no such userID exists');
          
        }
    }
    catch(e){
      throw Exception(e);
    }
  }

  //return a user doc given a username
  Future<QuerySnapshot> getUserbyUserName(String userName) async{
    try{
      QuerySnapshot userSnapshot = await userInfo.where('name',isEqualTo: userName).get();
      return userSnapshot;
    }
    catch(e)
    {
      throw Exception("User with this username doesn't exist : $e");
    }
  }

  //@Rafid : Newly added functions
  // Function to count total reports for posts on the current date
  Stream<int> countPostReportsToday() {
  DateTime now = DateTime.now();
  DateTime startOfDay = DateTime(now.year, now.month, now.day);
  DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

  return reportPost
      .where('time_reported', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .where('time_reported', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
      .snapshots()
      .map((querySnapshot) => querySnapshot.docs.length);
}


  //@Rafid : Newly added functions
  // Function to count total reports for users on the current date
 Stream<int> countUserReportsToday() {
  DateTime now = DateTime.now();
  DateTime startOfDay = DateTime(now.year, now.month, now.day);
  DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

  return reportUser
      .where('time_reported', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .where('time_reported', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
      .snapshots()
      .map((querySnapshot) => querySnapshot.docs.length);
}


  //@Rafid : Newly added functions
  //Function to retrieve total num. of posts made for the past week

Stream<Map<String, int>> getPostsWeeklyReport() {
  DateTime now = DateTime.now();
  DateTime startDate = now.subtract(const Duration(days: 6));

  return FirebaseFirestore.instance
      .collection('messages')
      .where('timePosted', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
      .where('timePosted', isLessThanOrEqualTo: Timestamp.fromDate(now))
      .snapshots()
      .map((querySnapshot) {
        Map<String, int> postsPerDay = {};
        for (int i = 0; i < 7; i++) {
          DateTime date = now.subtract(Duration(days: i));
          String formattedDate = DateFormat('MMM-dd').format(date);
          postsPerDay[formattedDate] = 0; // Initialize counts
        }

        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          Timestamp timePosted = data['timePosted'] as Timestamp;
          String formattedDate = DateFormat('MMM-dd').format(timePosted.toDate());
          if (postsPerDay.containsKey(formattedDate)) {
            postsPerDay[formattedDate] = postsPerDay[formattedDate]! + 1;
          }
        }
        return postsPerDay;
      });
}

  //fetches number of total signed in users for the past week
   Stream<Map<String, int>> getActiveUsersWeeklyReport() {
  DateTime now = DateTime.now();
  DateTime startDate = now.subtract(const Duration(days: 6));

  return dailySignIns
      .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
      .where('date', isLessThanOrEqualTo: Timestamp.fromDate(now))
      .snapshots()
      .map((querySnapshot) {
        Map<String, int> usersPerDay = {};
        for (int i = 0; i < 7; i++) {
          DateTime date = now.subtract(Duration(days: i));
          String formattedDate = DateFormat('MMM-dd').format(date);
          usersPerDay[formattedDate] = 0; // Initialize counts
        }

        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data();
          Timestamp date = data['date'] as Timestamp;
          Map<String, dynamic> usersSignedIn = data['users_signed_in'] ?? {};
          String formattedDate = DateFormat('MMM-dd').format(date.toDate());
          if (usersPerDay.containsKey(formattedDate)) {
            usersPerDay[formattedDate] = usersSignedIn.length;
          }
        }
        return usersPerDay;
      });
}

    //@Rafid : Newly added functions 17th Dec 2024
    //Function to update daily_sign_in collection -> used for daily sign in graph
    Future<void> handleDailySignIns(String uid)
    async {

      //uid must be provided
      final today = DateTime.now();
      final formattedDate = DateTime(today.year,today.month,today.day);
      final formattedTimeStamp = Timestamp.fromDate(formattedDate);

      try{
          //first check if date is there
          final querySnapShot = await dailySignIns.where('date',isEqualTo: formattedTimeStamp)
                                                   .get();
          
          //if date does not exist, we create an initialize the date
          if(querySnapShot.docs.isEmpty)
          {
             await dailySignIns.add({
              'date' : formattedTimeStamp,
              'users_signed_in' : {uid : 1},
             });
          }
          //else if date does exist, check if uid is already present
          else{
            //check if uid exist or not
            final doc = querySnapShot.docs.first;
            final docRef = dailySignIns.doc(doc.id); // need this to update a specific document
            final data = doc.data();

            //fetch the existing map
            final Map<String,dynamic> usersSignedIn = data['users_signed_in'] ?? {};

            if(usersSignedIn.containsKey(uid))
             {
              //if key exists, no further operations required
              return;
             }
            else
            {
              usersSignedIn[uid] = 1;
              await docRef.update({'users_signed_in' : usersSignedIn});
            }
          }
      }
      catch(e)
      {
        throw Exception("Error performing action : $e");
      }
      
    }
}