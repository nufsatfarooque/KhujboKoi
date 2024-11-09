


import 'package:khujbokoi/components/msg_options.dart';
import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

class MyButton extends StatelessWidget{
  final String messageId;
  
  final dynamic currentUser;
  
  final dynamic msgUserName;

  const MyButton({super.key, required this.messageId, required this.currentUser, required this.msgUserName});
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: () => showPopover(
        context: context,
        bodyBuilder: (context) => MsgOptions(messageId: messageId,currentUser: currentUser,msgUserName:msgUserName,),
        width:120, //chng later
        height: 150,
        backgroundColor: Colors.purple.shade100,
        direction: PopoverDirection.left,
        ),
        child: const Icon(Icons.more_vert),
    );
  }
  
}