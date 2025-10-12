// lib/models/expense.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id; // Changed to String for Firestore document ID
  final String userId; // Add userId to link to user
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final Map<String, double> shares; // friendId (String) -> share amount

  Expense({
    required this.id,
    required this.userId, // New field
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.shares,
  });

  // Convert an Expense object to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date), // Store DateTime as Timestamp
      'shares': shares,
    };
  }

  // Create an Expense object from a Firestore document
  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      amount: (data['amount'] as num).toDouble(),
      category: data['category'] as String,
      date: (data['date'] as Timestamp).toDate(),
      shares: Map<String, double>.from(data['shares'] as Map<String, dynamic>),
    );
  }
}