import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(

        backgroundColor: const Color(0xFFD5F2E8),
        appBar: AppBar(
          backgroundColor: const Color(0xFFD5F2E8),
          title: const Text("Log In"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
    child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: 300 ,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Welcome Back!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, color: Colors.green),

              ),
              const SizedBox(height: 40,),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true, //<-- SEE HERE
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true, //<-- SEE HERE
                  fillColor: Colors.white,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
               onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.homePage,
                );
                // Handle sign-up logic here
              },
                child: const Text(
                  'Log In',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20,),
              const Text("OR",
              textAlign: TextAlign.center,),
              const SizedBox(height: 20,),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.homePage,
                  );
                  // Handle sign-up logic here
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Keep button as wide as its contents
                  children: [
                    Image.asset(
                      'assets/images/google_logo.png', // Path to your local Google logo image
                      height: 24.0, // Logo size
                      width: 24.0,
                    ),
                    const SizedBox(width: 1.0),
                    const Text(
                      'Log in with your Google account',
                      style: TextStyle(
                        color: Colors.green, // Text color
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),


                /*Text(
                  'Log In with your Google Account',
                  style: TextStyle(fontSize: 14, color: Colors.green),
                ),
              ),*/

                            ),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don\'t have an account?',

                  ),
                  TextButton(
                      onPressed: (){
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 14, color: Colors.green),

                      )
                  ),
                ]
              )
            ],
          ),
        ),
        ),
      ),
        ),
      ),
    );
  }
}