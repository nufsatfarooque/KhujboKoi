import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../routes/app_routes.dart';

class HomeOwnerScreen extends StatefulWidget{
  const HomeOwnerScreen({super.key});

  @override
  _HomeOwnerScreenState createState()=>_HomeOwnerScreenState();
}

class _HomeOwnerScreenState extends State<HomeOwnerScreen>{
  @override
  void initState(){
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.green,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[Color(0xFF7FE38D), Colors.white],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
            ),
          ),
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "KhujboKoi?",
                style: TextStyle(color: Colors.green),
              ),
              const Text(
                "                                                 Landlord",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 7, // Smaller font size for the subtitle
                ),
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
          actions: [
            Container(
              width: 50,
              height: 50,
              child: const Icon(Icons.menu, color: Colors.green, size: 35,),
            ),
          ],
        ),

        body: ListView(
          children: [Padding(padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 150),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.zero,
                      elevation: 5,
                      backgroundColor: Colors.green.shade100,
                    ),
                    onPressed: (){
                      Navigator.pushNamed(
                        context,
                        '/addhouse',
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const[
                        Icon(Icons.add_circle_outline, color: Colors.black, size: 30,),
                        SizedBox(width: 20),
                        Text("Add House", style: TextStyle(fontSize: 25, color: Colors.black),
                        ),
                      ],
                    ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 150),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.zero,
                    elevation: 5,
                    backgroundColor: Colors.green.shade100,
                  ),
                  onPressed: (){
                    Navigator.pushNamed(
                      context,
                      '/viewListings',
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const[
                      Icon(Icons.menu_open, color: Colors.black, size: 30,),
                      SizedBox(width: 20),
                      Text("View List", style: TextStyle(fontSize: 25, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: ()
                  {
                    Navigator.pushNamed(
                      context,
                      '/notices',
                    );
                  },
                  child: const Text('View Latest Notices'),
                ),

              ],
            ),
            ),
          ],
        ),
      ),
    );
  }

}