import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  FirebaseAuth? _auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  AuthService() {
    try {
      _auth = FirebaseAuth.instance;
    } catch (e) {
      debugPrint('Firebase Auth not available: $e');
    }
  }

  Stream<User?> get authStateChanges {
    if (_auth == null) return Stream.value(null);
    return _auth!.authStateChanges();
  }

  User? get currentUser => _auth?.currentUser;
  String get currentUserId => _auth?.currentUser?.uid ?? '';
  String get currentUserName => _auth?.currentUser?.displayName ?? _auth?.currentUser?.email?.split('@').first ?? 'User';
  String get currentUserEmail => _auth?.currentUser?.email ?? '';
  String get currentUserInitial => currentUserName.isNotEmpty ? currentUserName[0].toUpperCase() : 'U';

  Future<UserCredential> signInWithEmail(String email, String password) async {
    if (_auth == null) throw Exception('Firebase not initialized');
    return await _auth!.signInWithEmailAndPassword(email: email.trim(), password: password);
  }

  Future<UserCredential> signUpWithEmail(String email, String password, String displayName) async {
    if (_auth == null) throw Exception('Firebase not initialized');
    final cred = await _auth!.createUserWithEmailAndPassword(email: email.trim(), password: password);
    await cred.user?.updateDisplayName(displayName.trim());
    return cred;
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return null;
      
      final googleAuth = await googleUser.authentication;
      
      // we just need the idToken for Firebase auth typically
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      return await _auth?.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      rethrow;
    }
  }

  Future<void> updateDisplayName(String name) async {
    await _auth?.currentUser?.updateDisplayName(name.trim());
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth?.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    try { await _googleSignIn.signOut(); } catch (_) {}
    await _auth?.signOut();
  }

  Future<void> deleteAccount() async {
    await _auth?.currentUser?.delete();
  }
}
