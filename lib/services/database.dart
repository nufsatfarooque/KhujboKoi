import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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
  //Create
   Future<void> addMessage(String note) {
     return messages.add({
      'message' : note,
      'timePosted' : Timestamp.now(),
      'downVotes' : 0,
      'upVotes' : 0,
      'userName' : "Rafid" //will change to account username when that is ready
     });
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

  //Update votes 
  Future<void> updateVotes(String messageId,int type)
  {
    if(type == downVoteValInc) {
    return messages.doc(messageId).update({
      'downVotes': FieldValue.increment(1),
    });
    
    }
    else if(type == downVoteValDec){
      return messages.doc(messageId).update(
        {
          'downVotes' : FieldValue.increment(-1),
        }
      );
    }
    else if(type == upVoteValInc)
    {
      return messages.doc(messageId).update(
         {
          'upVotes' : FieldValue.increment(1),
         }
      );
    }
    else if (type == upVoteValDec)
    {
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
    });
  }

    Future<void> addUserReport(String comment,String reportedBy,String reportedUser,String type)
   {
    return reportPost.add({
       'comment' : comment,
       'reported_by' : reportedBy,
       'reported_id' : reportedUser,
       'time_reported' : Timestamp.now(),
       'type' : type,
    });
  }
}