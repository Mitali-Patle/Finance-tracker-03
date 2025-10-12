// lib/models/friend.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  final String id; // Changed to String for Firestore document ID
  final String userId; // Add userId to link to user
  final String name;
  Friend({required this.id, required this.userId, required this.name});

  // Convert a Friend object to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
    };
  }

  // Create a Friend object from a Firestore document
  factory Friend.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Friend(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
    );
  }
}