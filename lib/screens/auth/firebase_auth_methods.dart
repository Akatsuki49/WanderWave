// ignore_for_file: use_build_context_synchronously
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/screens/home_screen.dart';
import 'login_screen.dart';
import '/widgets/snack_bar.dart';

class FirebaseAuthMethods {
  final FirebaseAuth _auth;
  FirebaseAuthMethods(this._auth);

  //State Management
  Stream<User?> get authState => FirebaseAuth.instance.authStateChanges();

  User get user => _auth.currentUser!;

  //SignUp using Email
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) {
            return HomeScreen();
          },
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      displaySnackBar(context, e.message!);
    }
  }

  //SignIn using Email
  Future<void> signInWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) {
            return HomeScreen();
          },
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      displaySnackBar(context, e.message!);
    }
  }

  // GOOGLE SIGN IN
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // ignore: unused_local_variable
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) {
            return HomeScreen();
          },
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      displaySnackBar(context, e.message!);
    }
  }

  //Sign Out
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) {
            return const LoginScreen();
          },
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      displaySnackBar(context, e.message!);
    }
  }

  //CHECK FOR EXISTING PROFILE
  Future<bool> checkProfile() async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((value) {
      if (value.exists) {
        return true;
      } else {
        return false;
      }
    });
  }
}
