import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

final String GOOGLE_AUTH_CLIENT_ID = dotenv.env["GOOGLE_CLIENT_ID"] ?? '';

class AdminAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<User?> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();
      if (gUser == null) return null;

      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      final String? idToken = gAuth.idToken;
      final String? accessToken = gAuth.accessToken;

      if (idToken == null) {
        throw Exception("Failed to retrieve idToken from GoogleSignIn");
      }

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user;

      if (user != null) {
        await _firestore.collection('admins').doc(user.uid).set({
          'email': user.email,
          'displayName': user.displayName,
          'lastSignIn': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
    } catch (_) {}
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
