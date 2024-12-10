


import 'package:khujbokoi/components/msg_options.dart';
import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
var height = 86.0;
class MyButton extends StatelessWidget{
  final String messageId;
  
  
  final dynamic msgUserName;
  
  final dynamic currentUserName;

  

  const MyButton({super.key, required this.messageId, required this.currentUserName, required this.msgUserName});
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
  onTap: () {
    // Determine the number of buttons in MsgOptions
    final int numberOfButtons = currentUserName == msgUserName ? 1 : 2;

    // Calculate the dynamic height
    const double buttonHeight = 46.0; // Fixed height of each button
    final double height = numberOfButtons * buttonHeight;

    showPopover(
      context: context,
      bodyBuilder: (context) => MsgOptions(
        messageId: messageId,
        currentUserName: currentUserName,
        msgUserName: msgUserName,
      ),
      width: 170, // Adjust as needed
      height: height, // Dynamic height
      backgroundColor: Colors.green.shade100,
      direction: PopoverDirection.left,
    );
  },
  child: const Icon(Icons.more_vert),
);

  
}
}