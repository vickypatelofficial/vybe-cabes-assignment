import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class FirebaseAuthService {
  FirebaseAuth get _auth {
    return FirebaseAuth.instance;
  }

  UserModel? _userFromFirebase(User? user) {
    if (user == null) return null;
    return UserModel(
      uid: user.uid,
      email: user.email ?? 'rider@vybecabs.io',
      displayName: user.displayName ?? 'Vicky Patel',
      phoneNumber: user.phoneNumber ?? '+91 9876543210',
      photoUrl: user.photoURL,
    );
  }

  Stream<UserModel?> get authStateChanges {
    try {
      return _auth.authStateChanges().map(_userFromFirebase);
    } catch (_) {}
    return const Stream.empty();
  }

  UserModel? get currentUser {
    try {
      if (_auth.currentUser != null) {
        return _userFromFirebase(_auth.currentUser);
      }
    } catch (_) {}
    return null;
  }

  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (credential.user != null) {
        return _userFromFirebase(credential.user)!;
      }
    } catch (e) {
      throw Exception(e.toString());
    }

    throw Exception('Firebase Auth is not available or signIn failed.');
  }

  Future<UserModel> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      if (credential.user != null) {
        return _userFromFirebase(credential.user)!;
      }
    } catch (e) {
      throw Exception(e.toString());
    }

    throw Exception('Firebase Auth is not available or registration failed.');
  }

  Future<UserModel> signInWithDemoMode() async {
    return const UserModel(
      uid: 'usr_demo_vip',
      email: 'demo.rider@vybecabs.io',
      displayName: 'Vicky Patel',
      phoneNumber: '+91 98765 43210',
      walletBalance: 1250.0,
      rating: 4.98,
    );
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {}
  }
}
