import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  FirebaseAuth? _auth;

  AuthService() {
    try {
      _auth = FirebaseAuth.instance;
    } catch (e) {
      debugPrint('Firebase Auth not available yet: $e');
    }
  }

  Stream<User?> get authStateChanges {
    if (_auth == null) return Stream.value(null);
    return _auth!.authStateChanges();
  }

  User? get currentUser => _auth?.currentUser;

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    if (_auth == null) throw Exception('Firebase not configured. Please set up Firebase first.');
    return await _auth!.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    if (_auth == null) throw Exception('Firebase not configured. Please set up Firebase first.');
    return await _auth!.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    throw Exception('Google Sign-In is temporarily disabled.');
  }

  Future<void> signOut() async {
    if (_auth == null) return;
    await _auth!.signOut();
  }
}
