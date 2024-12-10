import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:khujbokoi/main.dart';
import 'package:khujbokoi/screen/notice.dart';


class FirebaseApi {

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

}