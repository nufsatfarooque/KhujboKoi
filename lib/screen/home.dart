import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screen/sign_up_screen.dart';
import '../screen/login_screen.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onLoginPress;
  const HomePage({Key? key, required this.onLoginPress}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      body: Padding(
        padding: const EdgeInsets.all(25.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      decoration: const InputDecoration(
                        hintText: 'Find Your New Location...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Current Location', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 10),
            // Property Grid with Buttons
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                mainAxisSpacing: 10.0,  // Vertical spacing between buttons
                crossAxisSpacing: 10.0,  // Horizontal spacing between buttons
                children: List.generate(4, (index) {
                  return PropertyButton(index: index);
                }),
              ),
            ),

            TextButton(
              onPressed: widget.onLoginPress,
              /*onPressed: () {
                Navigator.pushNamed(context, '/login_screen');
                // Handle view latest notices action
              },*/
              child: const Text('View Latest Notices'),
            ),
          ],
        ),

      ),
      /*bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index){
          setState(() {
            myindex=index;
          });
        },
        currentIndex: myindex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'House',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Reviews',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
      ),*/

    ),
    );
  }
}

class PropertyButton extends StatefulWidget {
  final int index;

  const PropertyButton({Key? key, required this.index}) : super(key: key);

  @override
  _PropertyButtonState createState() => _PropertyButtonState();
}

class _PropertyButtonState extends State<PropertyButton> {
  List<String> titles = [
    'Family Flat Rent',
    'Office Flat Rent',
    'Bachelor Flat Rent',
    'Sub-let Flat Rent'
  ];

  List<String> images = [
    'assets/family_flat.jpg',
    'assets/office_flat.jpg',
    'assets/bachelor_flat.jpg',
    'assets/sublet_flat.jpg'
  ];

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.zero,//all(10.0),
        elevation: 5,
      ),
      onPressed: () {
        // Define what happens when the button is pressed
        print('Pressed: ${titles[widget.index]}');
      },
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                images[widget.index],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titles[widget.index],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 5),
                const Text("Bed: 3, Bath: 3"),
                const Text("Rent: 18,000 BDT"),
                const Text("Mirpur 11, Mirpur"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
