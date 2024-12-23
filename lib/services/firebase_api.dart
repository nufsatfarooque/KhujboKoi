import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:khujbokoi/main.dart';
import 'package:khujbokoi/screen/notice.dart';
import 'package:khujbokoi/services/database.dart';


class FirebaseApi {

  DatabaseService database = DatabaseService();

  //function to initialize notifications
  final _firebaseMessaging = FirebaseMessaging.instance; //grabs an instance of firebase messaging
  //create an instance of Firebase Messaging
   Future<void> initNotification() async {
    //request permission from user (prompts the user)
    await _firebaseMessaging.requestPermission();
    //fetch FCM token for this device
    final fcmToken = await _firebaseMessaging.getToken();
    //print token
    if (kDebugMode) {
      print('Token: $fcmToken');
    }
    // initialize push notification
    initPushNotifications();
   }
  

  //function to handle received messages
   void handleMessage(RemoteMessage? notificationMsg)
   {
      if(notificationMsg == null) return;

      //navigate to notices board
     navigatorKey.currentState?.pushNamed(
      '/notice'
     );
   }
  //function to initialize foreground and background settings
Future initPushNotifications() async {
  // Handle notification if app was terminated and now opened
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      handleMessage(message); // Navigate to the desired screen
    }
  });

  // Attach event listeners for when a notification opens the app
  FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
}

//automatically saves a device token to user collection
 void saveDeviceToken() async {
     
  final currentUser = FirebaseAuth.instance.currentUser;
  String? fcmToken = await _firebaseMessaging.getToken();

  //Save to firestore
  if (fcmToken != null){
    var tokens = DatabaseService().userInfo;

    await tokens.doc(currentUser?.uid).update({
      'token':fcmToken,
      'createdAt':Timestamp.now(),
    });
  }
 }

}