import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:khujbokoi/core/property.dart'; //to import the Property class

class DatabaseService{
  //get collection of
  static const int downVoteValDec = -1; 
  static const int downVoteValInc = 0;
  static const int upVoteValInc = 1;
  static const int upVoteValDec = 2;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

  /// Updates all user documents in 'users' collection with last_signed_in = Timestamp.now()

   
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
      "dislikedBy": [] ,// List of user IDs who disliked
      "archive": false,
    });
  } catch (e) {
    throw Exception('Failed to add message');
  }
}

  //Returns the users collection as a stream
  Stream<QuerySnapshot> getUsersStream(){
    final usersStream = 
    userInfo.orderBy('last_signed_in',descending:  true).snapshots();
    return usersStream;
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

//Given a unique user name, retuns its UID
Future<String> getUIDbyUserName(String userName) async {
  QuerySnapshot userSnapshot = await userInfo.where('name', isEqualTo: userName).get();

  if (userSnapshot.docs.isNotEmpty) {
    return userSnapshot.docs[0].id; // Return the document ID of the first match
  } else {
    throw Exception("No user found with the username: $userName");
  }
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

    //This function will be used by admin to add a post related notice to a specififc user
    Future<void> addNoticeForUser(String uid, Map<String, dynamic> notice) async
    {
      try{

        //this is a general structure for nested collection .i.e sub collection in a collection
        final noticeRef = _firestore
                          .collection('user_system_notices')
                          .doc(uid)
                          .collection('notices')
                          .doc();
        
        await noticeRef.set(notice);
        if(kDebugMode)
        {
          print("Notice added: ${noticeRef.id}");
        }

      }catch(e){
        print("Error adding notice:$e");
      }
    }

    //Write by understanding when I have time
    
 /// Retrieve all notices for a specific user
  Future<List<Map<String, dynamic>>> getUserNotices(String userUid) async {
    try {
      final snapshot = await _firestore
          .collection('user_system_notices')
          .doc(userUid)
          .collection('notices')
          .get();

      if (snapshot.docs.isEmpty) {
        print("No notices found for user: $userUid");
        return [];
      }

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    } catch (e) {
      print("Error retrieving notices: $e");
      return [];
    }
  }

  /// Mark a specific notice as read
  Future<void> markNoticeAsRead(String userUid, String noticeId) async {
    try {
      final noticeRef = _firestore
          .collection('user_system_notices')
          .doc(userUid)
          .collection('notices')
          .doc(noticeId);

      await noticeRef.update({'isRead': true});
      print("Notice $noticeId marked as read.");
    } catch (e) {
      print("Error marking notice as read: $e");
    }
  }

  /// Delete a specific notice for a user
  Future<void> deleteNotice(String userUid, String noticeId) async {
    try {
      final noticeRef = _firestore
          .collection('user_system_notices')
          .doc(userUid)
          .collection('notices')
          .doc(noticeId);

      await noticeRef.delete();
      print("Notice $noticeId deleted.");
    } catch (e) {
      print("Error deleting notice: $e");
    }
  }
    

    Future<void> updateLastSignedInForAllUsers() async {
    try {
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();

      for (var doc in usersSnapshot.docs) {
        await doc.reference.update({'date_created': Timestamp.now()});
      }

      print("All users' last_signed_in updated successfully.");
    } catch (e) {
      print("Error updating last_signed_in: $e");
    }
  }

  //Stream to return the collection of listings docs
  Stream<List<Property>> getPropertiesStream()
  {
     return _firestore.collection('listings').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Property.fromFirestore(doc);
      }).toList();
    });
    }

  
   //Written 24th Feb by Rafid
   //A function to count all docs in the collection `listings` 
   //that has approved = False
   Future<int> countPendingApprovals() async {
    try{
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('listings')
                                                            .where('approved',isEqualTo: false)
                                                            .get();
                                    return querySnapshot.docs.length;
    }
    catch(e){
        throw("Error counting pending approvals: $e");
        
    }
   }
  }

