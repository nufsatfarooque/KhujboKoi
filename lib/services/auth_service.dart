import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
//import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Initialize GoogleSignIn with Web clientId
  //final GoogleSignIn _googleSignIn = GoogleSignIn(
  //  clientId:
  //      '582973375044-i4auclhfhcl0jutk7bkg24gkvti2gn3h.apps.googleusercontent.com', // Use your actual client ID
  //);

  // Create a user with email and password
  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      if (kDebugMode) {
        print("Error creating user: $e");
      }
    }
    return null;
  }

  // Sign in a user with email and password
  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      if (kDebugMode) {
        print("Error logging in user: $e");
      }
    }
    return null;
  }

  // Sign out the current user
  Future<void> signout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print("Error signing out: $e");
      }
    }
  }

  // Google Sign-In
 //Future<UserCredential?> loginWithGoogle() async {
 //  try {
 //    final googleUser = await _googleSignIn.signIn();
 //    if (googleUser == null) return null; // If user cancels the sign-in

 //    final googleAuth = await googleUser.authentication;
 //    final credential = GoogleAuthProvider.credential(
 //      idToken: googleAuth.idToken,
 //      accessToken: googleAuth.accessToken,
 //    );

 //    return await _auth.signInWithCredential(credential);
 //  } catch (e) {
 //    if (kDebugMode) {
 //      print('Error signing in with Google: $e');
 //    }
 //  }
 //  return null;
 //}
}