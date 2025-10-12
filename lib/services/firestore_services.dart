//firestore_services.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';
import '../models/friend.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize user document if it doesn't exist
  Future<void> initializeUserDocument(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      await _firestore.collection('users').doc(userId).set({
        'monthlyBudget': 10000.0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Add a new expense
  Future<void> addExpense(String userId, Expense expense) async {
    try {
      await _firestore.collection('users').doc(userId).collection('expenses').add(expense.toFirestore());
    } catch (e) {
      print('Error adding expense: $e');
      rethrow;
    }
  }

  // Get all expenses for a user (FIXED - removed orderBy to avoid index requirement)
  Stream<List<Expense>> getExpenses(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .snapshots()
        .map((snapshot) {
      final expenses = snapshot.docs.map((doc) {
        try {
          return Expense.fromFirestore(doc);
        } catch (e) {
          print('Error parsing expense ${doc.id}: $e');
          return null;
        }
      }).whereType<Expense>().toList();
      
      // Sort in memory instead of using Firestore orderBy
      expenses.sort((a, b) => b.date.compareTo(a.date));
      return expenses;
    });
  }

  // Update an existing expense
  Future<void> updateExpense(String userId, Expense expense) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .doc(expense.id)
          .update(expense.toFirestore());
    } catch (e) {
      print('Error updating expense: $e');
      rethrow;
    }
  }

  // Delete an expense
  Future<void> deleteExpense(String userId, String expenseId) async {
    try {
      await _firestore.collection('users').doc(userId).collection('expenses').doc(expenseId).delete();
    } catch (e) {
      print('Error deleting expense: $e');
      rethrow;
    }
  }

  // Add a new friend
  Future<void> addFriend(String userId, Friend friend) async {
    try {
      await _firestore.collection('users').doc(userId).collection('friends').add(friend.toFirestore());
    } catch (e) {
      print('Error adding friend: $e');
      rethrow;
    }
  }

  // Get all friends for a user (FIXED - removed orderBy to avoid index requirement)
  Stream<List<Friend>> getFriends(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .snapshots()
        .map((snapshot) {
      final friends = snapshot.docs.map((doc) {
        try {
          return Friend.fromFirestore(doc);
        } catch (e) {
          print('Error parsing friend ${doc.id}: $e');
          return null;
        }
      }).whereType<Friend>().toList();
      
      // Sort in memory instead of using Firestore orderBy
      friends.sort((a, b) => a.name.compareTo(b.name));
      return friends;
    });
  }

  // Delete a friend
  Future<void> deleteFriend(String userId, String friendId) async {
    try {
      await _firestore.collection('users').doc(userId).collection('friends').doc(friendId).delete();
      
      // Also remove this friend from any expenses
      final expenseDocs = await _firestore.collection('users').doc(userId).collection('expenses').get();
      for (var doc in expenseDocs.docs) {
        final data = doc.data();
        if (data['shares'] != null && data['shares'].containsKey(friendId)) {
          final shares = Map<String, dynamic>.from(data['shares']);
          shares.remove(friendId);
          await doc.reference.update({'shares': shares});
        }
      }
    } catch (e) {
      print('Error deleting friend: $e');
      rethrow;
    }
  }

  // --- User Profile Management ---
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      // Use set with merge to create document if it doesn't exist
      await _firestore.collection('users').doc(userId).set(data, SetOptions(merge: true));
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // --- Monthly Budget ---
  Future<void> setMonthlyBudget(String userId, double budget) async {
    try {
      // Use set with merge to create document if it doesn't exist
      await _firestore.collection('users').doc(userId).set({
        'monthlyBudget': budget,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error setting monthly budget: $e');
      rethrow;
    }
  }

  Stream<double> getMonthlyBudget(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return 10000.0; // Default budget
      }
      final data = snapshot.data();
      return (data?['monthlyBudget'] as num?)?.toDouble() ?? 10000.0;
    });
  }
}