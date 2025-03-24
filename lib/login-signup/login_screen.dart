import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:khujbokoi/core/firestore.dart';
import 'package:khujbokoi/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

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
                width: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Welcome Back!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 28, color: Colors.green),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _email,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _password,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        filled: true,
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
                      onPressed: _login,
                      child: const Text(
                        'Log In',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Forgot Password: show dialog with two options.
                    TextButton(
                      onPressed: _forgotPassword,
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    const Text(
                      "OR",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    //insert google sign in here later 
                    
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Don\'t have an account?'),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/sign_up_screen');
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(fontSize: 14, color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Navigate to the Home Screen after successful login
  goToHome(BuildContext context) => Navigator.pushNamed(
        context,
        '/bottom_nav',
      
          
      );
  goToHomeOwner(BuildContext context) => Navigator.pushNamed(
    context,
    '/homeOwnerScreen',


  );
  goToAdminHome(BuildContext context) => Navigator.pushNamed(
      context,
      '/admin_nav',

  );
  // Regular login with email and password
  void _login() async {
    final user = await _auth.loginUserWithEmailAndPassword(
      _email.text,
      _password.text,
    );
    if (user != null) {
      if (kDebugMode) {
        print("User logged in with email and password");
      }

      // Fetch the user's role from the database
      final userRole = await _auth.getUserRole(user.uid);

      // Redirect based on the role
      if (userRole == 'User') {
        // Navigate to the User Home screen
        // ignore: use_build_context_synchronously
        goToHome(context);
      } else if (userRole == 'Home Owner') {
        // Navigate to the Home Owner screen
        // ignore: use_build_context_synchronously
        goToHomeOwner(context);
      } else if (userRole == 'Restaurant Owner') {
        // Navigate to the Restaurant Owner screen
        // ignore: use_build_context_synchronously
        //Navigator.pushNamed(context, '/restaurantOwnerScreen');
      } else if (userRole == "Administrator"){
        goToAdminHome(context);
      }
      else {
        if (kDebugMode) {
          print("Invalid role: $userRole");
        }
      }
    } else {
      if (kDebugMode) {
        print("Email/password login failed.");
      }
    }

     

  }
  Future<void> _forgotPassword() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reset Password"),
          
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _forgotPasswordWithEmail();
                },
                child: const Text("Reset via Email"),
              ),
            ),
           
          ],
        );
      },
    );
  }
  Future<void> _forgotPasswordWithEmail() async {
    TextEditingController forgotEmailController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reset Password via Email"),
          content: TextField(
            controller: forgotEmailController,
            decoration: const InputDecoration(
              labelText: "Enter your email",
              hintText: "example@gmail.com",
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String email = forgotEmailController.text.trim();
                if (email.isEmpty) {
                  _showErrorDialog("Please enter a valid email address.");
                  return;
                }
                // Check Firestore for account existence.
                var querySnapshot = await firestoreDb
                    .collection("users")
                    .where("email", isEqualTo: email)
                    .get();
                if (querySnapshot.docs.isEmpty) {
                  Navigator.pop(context);
                  _showErrorDialog("No account found for the email: $email");
                  return;
                }
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                  Navigator.pop(context);
                  _showInfoDialog(
                    "Password Reset Email Sent",
                    "A reset link has been sent to $email. Please check your inbox (and spam folder).",
                  );
                } on FirebaseAuthException catch (e) {
                  Navigator.pop(context);
                  _showErrorDialog("Error: ${e.message}");
                } catch (e) {
                  Navigator.pop(context);
                  _showErrorDialog("Error sending password reset email: $e");
                }
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }
  void _showEmailNotVerifiedDialog(User user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Email Not Verified"),
          content: Text(
            "Your email (${user.email}) is not verified. Would you like us to resend the verification link?",
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _resendVerificationEmail(user);
              },
              child: const Text("Resend"),
            ),
          ],
        );
      },
    );
  }

  // Resend verification email.
  Future<void> _resendVerificationEmail(User user) async {
    try {
      await user.sendEmailVerification();
      _showInfoDialog(
        "Verification Email Sent",
        "A verification link has been resent to ${user.email}. Please check your inbox.",
      );
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      _showErrorDialog("Error sending verification email: $e");
    }
  }

  // Displays an error dialog.
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}



 //goToHome(BuildContext context) => Navigator.push(
 //       context,
 //       MaterialPageRoute(
 //           builder: (context) => HomePage(
 //                 onLoginPress: () {},
 //               )),
 //       
 //     );
 
