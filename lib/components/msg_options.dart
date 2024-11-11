import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khujbokoi/services/database.dart';
import 'package:flutter/material.dart';
import 'package:khujbokoi/screen/notice.dart';
class MsgOptions extends StatelessWidget {
  
  
  final String messageId;
  final String currentUser;
  
  final dynamic msgUserName;

  const MsgOptions({super.key, required this.messageId,required this.currentUser,required this.msgUserName});

   

  @override
  Widget build(BuildContext context) {
     const double buttonWidth = 200.0; // Set a consistent width for all buttons
    return Column(
      children: [
        //1st msg option
        if( currentUser ==msgUserName)

        SizedBox(
          width: buttonWidth,
          child: ElevatedButton(
            onPressed: (){
              DatabaseService().deleteMessage(messageId);
              Navigator.pop(context);
            }, 
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.delete),
                  const SizedBox(width: 8),
                  const Text("Delete"),
                ],
            ),
            
            ),
        ),
        SizedBox(
          width: buttonWidth,
          child: ElevatedButton(
            onPressed: (){}, 
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                  const Icon(Icons.report),
                  const SizedBox(width: 8,),
                  const Text("Report this post"),
              ],
            ),
          ),
        ),
         SizedBox(
          width: buttonWidth,
           child: ElevatedButton(
            onPressed: (){}, 
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                  const Icon(Icons.person_off_outlined),
                  const SizedBox(width: 8,),
                  const Text("Report this user"),
              ],
            ),
                   ),
         ),
      ],
    );
  }
}