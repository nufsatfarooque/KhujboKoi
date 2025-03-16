import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khujbokoi/core/firestore.dart';
import 'package:khujbokoi/routes/app_routes.dart';
import 'package:khujbokoi/services/auth_service.dart';
import 'package:khujbokoi/screen/home.dart';
import 'package:khujbokoi/services/database.dart';

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
  final DatabaseService database = DatabaseService(); // @Rafid : Need this for proper function of admin panel

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

  goToAdminHome(BuildContext context) => Navigator.pushNamed(
        context,
        '/admin_nav',
      
          
      );


  // Regular login with email and password
 // Navigate to the Home Screen after successful login
  goToUser(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(
                  onLoginPress: () {},
                )),
      );
  // goToHomeOwner(BuildContext context) => Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => HomeOwnerPage(
  //                 onLoginPress: () {},
  //               )),
  //     );
  // goToRestOwner(BuildContext context) => Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => RestOwnerPage(
  //                 onLoginPress: () {},
  //               )),
  //     );

  // Regular login with email and password
    // Regular login with email and password
  void _login() async {
    final user = await _auth.loginUserWithEmailAndPassword(
      _email.text,
      _password.text,
    );

    if (user != null) {

          print("User logged in with email and password");
      final snapshot =
          await firestoreDb.collection("users").doc(user.uid).get();
      final data = snapshot.data();
      print(data);
      String role = data?["role"];
      //user successfully logged in, so keep a record of its signin in the daily_sign_in collections
      database.handleDailySignIns(user.uid);
      
      //Update user last sign in to user doc in users collection
      await DatabaseService().userInfo.doc(user.uid).update({
        'last_signed_in': Timestamp.now(),
      });

      final banned = data!.containsKey("banned") ? data["banned"] : false;

     if (banned == true) {
      // Convert the Timestamp to DateTime then format it to a String.
      final bannedTillTimestamp = data?["banned_till"] as Timestamp;
      final bannedTillDate = bannedTillTimestamp.toDate();

      if(bannedTillDate.isBefore(DateTime.now())){
        //unban the user
        await DatabaseService().userInfo.doc(user.uid).update({
          'banned':false,
          'banned_till': FieldValue.delete(),
        });
      }
      else{
             final bannedTillString = DateFormat('yyyy-MM-dd HH:mm').format(bannedTillTimestamp.toDate());
      _showBannedMessage(context, bannedTillString);
      return;
      }
 
    }
  
    if(banned == false){
       if (role == "Home Owner") {
        //goToHomeOwner(context);
        // goToHome(context); // temporary
      } else if (role == "Restaurant Owner") {
        //goToRestOwner(context);
      }
      else if (role == "Administrator"){
        goToAdminHome(context);
      } else if(role == "User"){
        goToHome(context);
      }
       else {
      // Show a dialog when credentials don't match
      _showLoginErrorDialog(context);
    }
    }
    }
     
  }

}

  void _showLoginErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Login Failed"),
          content: const Text("The email or password you entered is incorrect."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showBannedMessage(BuildContext context, String banned_till){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Account Banned"),
          content: Text("Your account has been banned till $banned_till"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  } 




 //goToHome(BuildContext context) => Navigator.push(
 //       context,
 //       MaterialPageRoute(
 //           builder: (context) => HomePage(
 //                 onLoginPress: () {},
 //               )),
 //       
 //     );