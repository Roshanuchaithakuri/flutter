import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? getCurrentUser() => _auth.currentUser;

  // Get auth state changes
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign up with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(dynamic e) {
    String message;
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        case 'email-already-in-use':
          message = 'Email is already registered.';
          break;
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'invalid-email':
          message = 'The email address is badly formatted.';
          break;
        case 'operation-not-allowed':
          message = 'Email & Password accounts are not enabled.';
          break;
        default:
          message = 'An undefined error occurred.';
      }
    } else {
      message = 'An error occurred during authentication.';
    }
    return message;
  }
}