import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to\nKhujboKoi',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 30,
                    color: Colors.green,
                ),
              ),
              // Icon for rent house
              SizedBox(height: 20),
              Container(
                width: 200,
                height: 200,
              child: Image.asset('assets/images/house.png')

              ),
              SizedBox(height: 20),

              // Text description
              Text(
                'Find And Rent House Faster\nWith The KhujboKoi App',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),

              SizedBox(height: 60),

              // Log In Button
              SizedBox(
                width: double.infinity, // Button will take the full width
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Button background color
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () {
                    // Handle log in action
                    Navigator.pushNamed(context, '/login_screen'); // Navigate to login page
                  },
                  child: Text(
                    'Log In',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Sign Up Button
              SizedBox(
                width: double.infinity, // Button will take the full width
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    side: BorderSide(color: Colors.green, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () {
                    // Handle sign up action
                    Navigator.pushNamed(context, '/sign_up_screen'); // Navigate to signup page
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 18, color: Colors.green),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
