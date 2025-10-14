//services/auth_services.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmail(
    String email,
    String password,
    String username,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      if (credential.user != null) {
        await _createUserProfile(credential.user!.uid, username, email);
      }

      notifyListeners();
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Create user profile if it doesn't exist
      if (userCredential.user != null) {
        final userDoc =
            await _firestore
                .collection('users')
                .doc(userCredential.user!.uid)
                .get();

        if (!userDoc.exists) {
          await _createUserProfile(
            userCredential.user!.uid,
            userCredential.user!.displayName ?? 'User',
            userCredential.user!.email ?? '',
          );
        }
      }

      notifyListeners();
      return userCredential;
    } catch (e) {
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    notifyListeners();
  }

  // Create user profile in Firestore
  Future<void> _createUserProfile(
    String uid,
    String username,
    String email,
  ) async {
    await _firestore.collection('users').doc(uid).set({
      'username': username,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'favorites': [],
      'reading': [],
      'read': [],
    });
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser == null) return null;

    try {
      final doc =
          await _firestore.collection('users').doc(currentUser!.uid).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }
}
