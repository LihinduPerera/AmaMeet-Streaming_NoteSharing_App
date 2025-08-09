import 'package:ama_meet/utils/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _cachedUserModel;

  Stream<User?> get authChanges => _auth.authStateChanges();

  User get user => _auth.currentUser!;

  Future<bool> signInWithGoogle(BuildContext context) async {
    bool result = false;

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        if (userCredential.additionalUserInfo!.isNewUser) {
          UserModel newUser = UserModel(
            username: user.displayName ?? 'No Name',
            uid: user.uid,
            profilePhoto: user.photoURL ?? '',
          );

          await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
          _cachedUserModel = newUser;
        } else {
          await getUserData();
        }
        result = true;
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message ?? 'Something went wrong');
    }

    return result;
  }

  Future<UserModel?> getUserData() async {
    if (_cachedUserModel != null) {
      return _cachedUserModel;
    }

    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').doc(user.uid).get();
      if (snapshot.exists) {
        _cachedUserModel = UserModel.fromMap(snapshot.data()!);
        return _cachedUserModel;
      }
    } catch (e) {
      print('Error fetching user: $e');
    }

    return null;
  }

  Future<void> signOut() async {
    _cachedUserModel = null;
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}
