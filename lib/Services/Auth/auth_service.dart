import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthService extends ChangeNotifier {
  // FirebaseAuth and Firestore instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with email and password
  Future<UserCredential> signInWithEmailandPassword(String email, String password) async {
    try {
      // Sign in with FirebaseAuth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update or create a Firestore document for the signed-in user
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      }, SetOptions(merge: true));

      return userCredential;
    } catch (e) {
      // Handle any other exceptions
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Create a new user with email, password, and display name
  Future<UserCredential> signUpWithEmailandPassword(String email, String password, String displayName) async {
    try {
      // Create a new user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user profile with display name
      if (userCredential.user != null) {
        await userCredential.user!.updateProfile(displayName: displayName);

        // Create a Firestore document for the new user
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'displayName': displayName,
        }, SetOptions(merge: true));
      }

      return userCredential;
    } catch (e) {
      // Handle any other exceptions
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
