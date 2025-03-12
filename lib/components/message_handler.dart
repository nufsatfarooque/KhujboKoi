import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageHandler extends StatefulWidget {
  const MessageHandler({super.key});

  @override
  State<MessageHandler> createState() => _MessageHandlerState();
}

class _MessageHandlerState extends State<MessageHandler> {
  
  final _db = FirebaseFirestore.instance;
  final _fcm = FirebaseMessaging.instance;

  @override
  void initState(){
    super.initState();
    //handle the message when received by the device
    //request user permission
    _requestNotificationPermission(); //created method

    //For foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message){
      if(message.notification != null){
        _showNotificationDialog(
          title: message.notification!.title ?? "Notification",
          body: message.notification!.body ?? "NULL", 
        );
      }
    });

    // onBkgMsg may be implemented later

  }
  
  //Request notification permissions
  void _requestNotificationPermission() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge:  true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    //debug lines
    if(kDebugMode){
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User denied permission');
    }
    }
  }

  void _showNotificationDialog({required String title,required String body}){
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        content: ListTile(
          title: Text(title),
          subtitle: Text(body),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop,
            child: const Text("OK"))
        ],
      ));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('Listening for FCM messages...'),
      ),
    );
  }

}

