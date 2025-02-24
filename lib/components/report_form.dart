import 'package:flutter/material.dart';
import 'package:khujbokoi/services/database.dart';

class ReportForm extends StatelessWidget{

  final String reportedBY;
  final String messageId;
  final String type;
  final String messageOwner;

   ReportForm({super.key, 
                    required this.reportedBY, 
                    required this.messageId, 
                    required this.type, 
                    required this.messageOwner, 
                    });
  
  final TextEditingController _commentController = TextEditingController();
  // Offensive, Encourages Violence, False information, Political Bias, others
  final List<String> _postTypes = [
    'Offensive',
    'Fake info',
    'Political Bias',
    'Post promotes violence',
    'Others (please mention in comment)',
  ];
  // Imposter, Fake account, Bot account, Fake name, Fraud, Harrassment or bullying
  final List<String> _userTypes = [
    'Fake account',
    'Bot account',
    'Fake name',
    'Fraud',
    'Harrasment or bullying',
  ];
  @override
  Widget build(BuildContext context) {
   String? selectedType;

   return AlertDialog(
      title: Text(
        type == "post" ? "Report Post" : "Report User",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
       child:  Column(
           mainAxisSize: MainAxisSize.min,
           children: [
            if (type == "post")
              DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Select Type",
                ),
                value: selectedType,
                items:_postTypes
                    .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(), 
                    onChanged: (newValue){
                      selectedType = newValue!;
                    },
              ),
            if (type == "user")
            DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Select Type",
                ),
                value: selectedType,
                items:_userTypes
                    .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(), 
                    onChanged: (newValue){
                      selectedType = newValue!;
                    },
              ),
              const SizedBox(height: 16,),
              //comment field
              TextField(
                controller: _commentController,
                maxLines: null, //grows automatically with text length
                decoration: const InputDecoration(
                  labelText: "Reson for reporting",
                  border: OutlineInputBorder(),//creates rounded rectangle border
                  hintText: "Describe the issue"
                ),
              )
           ],
        )
    
       
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
         child: const Text("Cancel"),),
         ElevatedButton(
          onPressed: () {
            //null field handling
            if(selectedType == null || selectedType!.isEmpty){
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please select a report type.")),
              );
              return;
            }
            //call respective database report function
            if(type == "post"){
              DatabaseService().addPostReport(
                _commentController.text, 
                reportedBY,
                messageId, 
                selectedType!);
            }
            else{
              DatabaseService().addUserReport(
                _commentController.text, 
                reportedBY, 
                messageOwner,
                selectedType!);
            }
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Report submitted successfully.")),
            );
          },
           child: Text(type == "post" ? "Report Post" : "Report User"),)
      ],
   );
   
  }
  
}