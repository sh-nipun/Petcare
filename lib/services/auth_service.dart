// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sign Up with Role [cite: 31, 33]
  Future<UserCredential?> signUpWithEmailPassword(String email, String password, String name, String role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      
      if (user != null) {
        // Save user profile and role to Firestore
        await _db.collection('users').doc(user.uid).set({
          'fullName': name,
          'email': email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Log In [cite: 32]
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}