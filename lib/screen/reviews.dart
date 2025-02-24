import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({Key? key}) : super(key: key);

  @override
  _ReviewsPageState createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  @override
  void initState() {
    super.initState();

    // Set the status bar color to green
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.green, // Status bar color
      ),
    );
  }
  String searchText = '';
  String location = 'Boardbazar';

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
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
        title: const Text("KhujboKoi?", style: TextStyle(color: Colors.green)),
        backgroundColor: Colors.transparent,
        actions: [
          Container(
            width: 50,
            height: 50,
            child: const Icon(Icons.menu, color: Colors.green),
          ),
        ],
      ),
      body: ListView(//SingleChildScrollView(
        //child:
        children: [
          Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Give Review" Container
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //first  row with "Give review"
                  Row(
                    children: [
                      const Icon(Icons.add_circle_outline, color: Colors.green),
                      const SizedBox(width: 10),
                      const Text(
                        "Give Review",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  //second row with the search bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                      //width: 20,
                      height: 60,
                      decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 10),
                        Expanded(
                         child: TextField(
                            onChanged: (value){
                              setState(() {
                                searchText=value;
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Find Your Restaurants and Houses',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    )
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Showing Results for Current Location
            Text(
              'Showing results for $location',
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            TextButton(
              onPressed: () {
                // Define your location change logic here
              },
              child: const Text(
                'Not in this location?',
                style: TextStyle(color: Colors.green),
              ),
            ),
            const SizedBox(height: 20),

            // Elevated Buttons for Restaurants and House
            //Expanded(
             // child:
            Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 70),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black12),
                    ),
                    onPressed: () {
                      // Define the action for "Restaurants" button here
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Restaurants",
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                        Icon(Icons.restaurant_menu, color: Colors.black),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 70),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black12),
                    ),
                    onPressed: () {
                      // Define the action for "House" button here
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "House",
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                        Icon(Icons.house, color: Colors.black),
                      ],
                    ),
                  ),
                ],
              ),
            //),
          ],
        ),
      ),
      //),
      ],
      ),
    ),
    );
  }
}
