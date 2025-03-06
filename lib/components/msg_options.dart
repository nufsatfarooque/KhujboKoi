import 'package:khujbokoi/components/report_form.dart';
import 'package:khujbokoi/services/database.dart';
import 'package:flutter/material.dart';
class MsgOptions extends StatelessWidget {
  
  
  final String messageId;
  
  final dynamic msgUserName;
  
  final dynamic currentUserName;

  const MsgOptions({super.key, required this.messageId,required this.currentUserName,required this.msgUserName});

   

  @override
  Widget build(BuildContext context) {
     const double buttonWidth = 200.0; // Set a consistent width for all buttons
    
    return Column(
      children: [
        //1st msg option
        if( currentUserName ==msgUserName)
        
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
         if( currentUserName != msgUserName)
        SizedBox(
          width: buttonWidth,
          child: ElevatedButton(
            onPressed: (){
              showDialog(
                context: context, 
                builder: (context) => ReportForm(
                  reportedBY: currentUserName, 
                  messageId: messageId, 
                  type: "post", 
                  messageOwner: msgUserName));
            }, 
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
          if( currentUserName != msgUserName)
         SizedBox(
          width: buttonWidth,
           child: ElevatedButton(
            onPressed: (){
              showDialog(
                context: context, 
                builder: (context) => ReportForm(
                  reportedBY: currentUserName, 
                  messageId: messageId, 
                  type: "user",
                  messageOwner: msgUserName));
            }, 
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