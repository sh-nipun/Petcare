// lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String role; // 'Pet Owner' or 'Veterinarian'

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'Pet Owner',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}