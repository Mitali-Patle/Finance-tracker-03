//auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailPassword(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user's name in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name,
        'createdAt': Timestamp.now(),
        // Add other user profile details here
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error during signup: ${e.code} - ${e.message}");
      throw Exception(e.message);
    } catch (e) {
      print("Error during signup: $e");
      throw Exception('Failed to sign up.');
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error during signin: ${e.code} - ${e.message}");
      throw Exception(e.message);
    } catch (e) {
      print("Error during signin: $e");
      throw Exception('Failed to sign in.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error during signout: $e");
      throw Exception('Failed to sign out.');
    }
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error during password reset: ${e.code} - ${e.message}");
      throw Exception(e.message);
    } catch (e) {
      print("Error during password reset: $e");
      throw Exception('Failed to send password reset email.');
    }
  }
}