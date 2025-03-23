import 'package:flutter/material.dart';
import 'package:khujbokoi/core/firestore.dart';
import 'package:khujbokoi/services/auth_service.dart';
import 'package:khujbokoi/login-signup/login_screen.dart';
import 'dart:developer' as developer;

// (Optional) Helper to format phone if needed. In this case, we require input to be in international format.
String formatPhone(String phone) {
  // If already in international format, return as is.
  if (phone.startsWith('+')) return phone;
  // Otherwise, you might decide to convert, but now we require users to input in correct format.
  return phone;
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = AuthService();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  // User types
  final List<String> _userTypes = ["User", "Home Owner", "Restaurant Owner"];
  String? _selectedUserType;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFD5F2E8),
        appBar: AppBar(
          backgroundColor: const Color(0xFFD5F2E8),
          title: const Text("Sign Up"),
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
                      "Welcome!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 28, color: Colors.green),
                    ),
                    const Text(
                      "Sign Up for the KhujboKoi App",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.green),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _name,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _email,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        hintText: "e.g. 01832560411",
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _password,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _confirmPassword,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Select User Type",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._userTypes.map((type) {
                      return RadioListTile<String>(
                        title: Text(type),
                        value: type,
                        groupValue: _selectedUserType,
                        onChanged: (value) {
                          setState(() {
                            _selectedUserType = value;
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: _signup,
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signup() async {
    String errorMessage = "";

    // Updated phone validation: phone must be exactly 11 digits.
    final phonePattern = RegExp(r'^[0-9]{11}$');
    if (!phonePattern.hasMatch(_phone.text.trim())) {
      errorMessage += "Invalid phone number. It must be 11 digits long.\n";
    }

    final emailPattern =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailPattern.hasMatch(_email.text.trim())) {
      errorMessage += "Invalid email format.\n";
    }

    // Check for password minimum length requirement.
    if (_password.text.trim().length < 6) {
      errorMessage += "Password must be at least 6 characters long.\n";
    }

    if (_password.text.trim() != _confirmPassword.text.trim()) {
      errorMessage += "Passwords do not match.\n";
    }

    if (_selectedUserType == null) {
      errorMessage += "Please select a user type.\n";
    }

    if (errorMessage.isNotEmpty) {
      _showPopup(errorMessage, Colors.redAccent, showCloseButton: true);
      return;
    }

    try {
      // Create user with email & password
      final user = await _auth.createUserWithEmailAndPassword(
        _email.text.trim(),
        _password.text.trim(),
      );

      if (user != null) {
        developer.log("User created successfully!");

        // Send email verification
        await user.sendEmailVerification();

        // Inform the user to check their inbox
        _showPopup(
          "Successfully signed up! A verification email has been sent to ${user.email}. Please verify your email before logging in.",
          Colors.green,
          showCloseButton: false,
        );

        // Save user data in Firestore with the formatted phone number.
        var data = {
          "name": _name.text.trim(),
          "email": user.email,
          "phoneNumber": formatPhone(_phone.text.trim()),
          "role": _selectedUserType
        };
        await firestoreDb.collection("users").doc(user.uid).set(data);

        // Redirect to login after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        });
      }
    } catch (e) {
      developer.log("User creation failed: $e");
      _showPopup("Sign-up failed: ${e.toString()}", Colors.redAccent,
          showCloseButton: true);
    }
  }

  void _showPopup(String message, Color bgColor,
      {required bool showCloseButton}) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (showCloseButton)
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:khujbokoi/core/firestore.dart';
// import 'package:khujbokoi/screen/auth_service.dart';
// import 'package:khujbokoi/screen/login_screen.dart';
// import 'dart:developer' as developer;

// // (Optional) Helper to format phone if needed. In this case, we require input to be in international format.
// String formatPhone(String phone) {
//   // If already in international format, return as is.
//   if (phone.startsWith('+')) return phone;
//   // Otherwise, you might decide to convert, but now we require users to input in correct format.
//   return phone;
// }

// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});

//   @override
//   _SignUpScreenState createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {
//   final _auth = AuthService();
//   final _name = TextEditingController();
//   final _email = TextEditingController();
//   final _phone = TextEditingController();
//   final _password = TextEditingController();
//   final _confirmPassword = TextEditingController();

//   // User types
//   final List<String> _userTypes = ["User", "Home Owner", "Restaurant Owner"];
//   String? _selectedUserType;

//   @override
//   void dispose() {
//     _name.dispose();
//     _email.dispose();
//     _phone.dispose();
//     _password.dispose();
//     _confirmPassword.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: const Color(0xFFD5F2E8),
//         appBar: AppBar(
//           backgroundColor: const Color(0xFFD5F2E8),
//           title: const Text("Sign Up"),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ),
//         body: Center(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: SizedBox(
//                 width: 300,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     const Text(
//                       "Welcome!",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(fontSize: 28, color: Colors.green),
//                     ),
//                     const Text(
//                       "Sign Up for the KhujboKoi App",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(fontSize: 18, color: Colors.green),
//                     ),
//                     const SizedBox(height: 40),
//                     TextField(
//                       controller: _name,
//                       decoration: const InputDecoration(
//                         labelText: 'Name',
//                         filled: true,
//                         fillColor: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     TextField(
//                       controller: _email,
//                       decoration: const InputDecoration(
//                         labelText: 'Email',
//                         filled: true,
//                         fillColor: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     TextField(
//                       controller: _phone,
//                       decoration: const InputDecoration(
//                         labelText: 'Phone',
//                         hintText: "e.g. +8801832560411",
//                         filled: true,
//                         fillColor: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     TextField(
//                       controller: _password,
//                       decoration: const InputDecoration(
//                         labelText: 'Password',
//                         filled: true,
//                         fillColor: Colors.white,
//                       ),
//                       obscureText: true,
//                     ),
//                     const SizedBox(height: 16),
//                     TextField(
//                       controller: _confirmPassword,
//                       decoration: const InputDecoration(
//                         labelText: 'Confirm Password',
//                         filled: true,
//                         fillColor: Colors.white,
//                       ),
//                       obscureText: true,
//                     ),
//                     const SizedBox(height: 24),
//                     const Text(
//                       "Select User Type",
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 8),
//                     ..._userTypes.map((type) {
//                       return RadioListTile<String>(
//                         title: Text(type),
//                         value: type,
//                         groupValue: _selectedUserType,
//                         onChanged: (value) {
//                           setState(() {
//                             _selectedUserType = value;
//                           });
//                         },
//                       );
//                     }),
//                     const SizedBox(height: 24),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 16.0),
//                         backgroundColor: Colors.green,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                       ),
//                       onPressed: _signup,
//                       child: const Text(
//                         'Sign Up',
//                         style: TextStyle(fontSize: 18, color: Colors.white),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _signup() async {
//     String errorMessage = "";

//     // Updated phone validation: must start with +88 and be 14 characters total.
//     final phonePattern = RegExp(r'^\+88[0-9]{11}$');
//     if (!phonePattern.hasMatch(_phone.text.trim())) {
//       errorMessage += "Invalid phone number. It must start with '+88' and be 14 characters long.\n";
//     }

//     final emailPattern =
//         RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
//     if (!emailPattern.hasMatch(_email.text.trim())) {
//       errorMessage += "Invalid email format.\n";
//     }

//     if (_password.text.trim() != _confirmPassword.text.trim()) {
//       errorMessage += "Passwords do not match.\n";
//     }

//     if (_selectedUserType == null) {
//       errorMessage += "Please select a user type.\n";
//     }

//     if (errorMessage.isNotEmpty) {
//       _showPopup(errorMessage, Colors.redAccent, showCloseButton: true);
//       return;
//     }

//     try {
//       // Create user with email & password
//       final user = await _auth.createUserWithEmailAndPassword(
//         _email.text.trim(),
//         _password.text.trim(),
//       );

//       if (user != null) {
//         developer.log("User created successfully!");

//         // Send email verification
//         await user.sendEmailVerification();

//         // Inform the user to check their inbox
//         _showPopup(
//           "Successfully signed up! A verification email has been sent to ${user.email}. Please verify your email before logging in.",
//           Colors.green,
//           showCloseButton: false,
//         );

//         // Save user data in Firestore with the formatted phone number.
//         var data = {
//           "name": _name.text.trim(),
//           "email": user.email,
//           "phoneNumber": formatPhone(_phone.text.trim()),
//           "role": _selectedUserType
//         };
//         await firestoreDb.collection("users").doc(user.uid).set(data);

//         // Redirect to login after a short delay
//         Future.delayed(const Duration(seconds: 2), () {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const LoginScreen()),
//           );
//         });
//       }
//     } catch (e) {
//       developer.log("User creation failed: $e");
//       _showPopup("Sign-up failed: ${e.toString()}", Colors.redAccent,
//           showCloseButton: true);
//     }
//   }

//   void _showPopup(String message, Color bgColor, {required bool showCloseButton}) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           child: Container(
//             decoration: BoxDecoration(
//               color: bgColor,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   message,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 if (showCloseButton)
//                   ElevatedButton(
//                     onPressed: () => Navigator.of(context).pop(),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                     ),
//                     child: const Text(
//                       "Close",
//                       style: TextStyle(color: Colors.green),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }