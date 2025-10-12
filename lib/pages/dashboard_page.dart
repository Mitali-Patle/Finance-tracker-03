// lib/pages/dashboard_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/friend.dart';
import '../models/expense.dart';
import '../services/firestore_services.dart';
import '../services/auth_service.dart';
import '../feedback_form.dart';
import '../services/notification_service.dart';
import 'home_page.dart'; // NEW
import 'expenses_page.dart';
import 'friends_page.dart';
import 'analytics_page.dart';
import 'summary_page.dart';
import 'chatbot_pages.dart';
import 'profile_page.dart';
import 'help_page.dart';

final NotificationService _notificationService = NotificationService();


class DashboardPage extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onToggleTheme;

  const DashboardPage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _tabIndex = 0;
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  late User? _currentUser;

  List<Friend> _friends = [];
  List<Expense> _expenses = [];
  double _monthlyBudget = 10000;
  double _usdInr = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.getCurrentUser();
    if (_currentUser != null) {
      _initializeUser();
    }
    _fetchUsdInr();
  }

  Future<void> _initializeUser() async {
    try {
      await _firestoreService.initializeUserDocument(_currentUser!.uid);
      _listenToData(_currentUser!.uid);
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing user: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _listenToData(String userId) {
    _firestoreService.getFriends(userId).listen((friends) {
      if (mounted) {
        print('Received ${friends.length} friends');
        setState(() {
          _friends = friends;
        });
      }
    }, onError: (e) {
      print('Error listening to friends: $e');
    });

    _firestoreService.getExpenses(userId).listen((expenses) {
      if (mounted) {
        print('Received ${expenses.length} expenses');
        setState(() {
          _expenses = expenses;
        });
        _checkBudgetExceededSnack();
      }
    }, onError: (e) {
      print('Error listening to expenses: $e');
    });

    _firestoreService.getMonthlyBudget(userId).listen((budget) {
      if (mounted) {
        print('Received budget: $budget');
        setState(() {
          _monthlyBudget = budget;
        });
        _checkBudgetExceededSnack();
      }
    }, onError: (e) {
      print('Error listening to budget: $e');
    });
  }

  Future<void> _fetchUsdInr() async {
    try {
      final res = await http.get(Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'));
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final inr = (data['rates']?['INR'] as num?)?.toDouble() ?? 0;
        setState(() => _usdInr = inr);
      }
    } catch (e) {
      print('Error fetching USD/INR: $e');
    }
  }

 void _checkBudgetExceededSnack() {
  if (_currentUser == null || !mounted) return;
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  final monthEnd = DateTime(now.year, now.month + 1, 1);
  final total = _expenses
      .where((e) =>
          e.date.isAfter(monthStart.subtract(const Duration(milliseconds: 1))) &&
          e.date.isBefore(monthEnd))
      .fold<double>(0, (p, e) => p + e.amount);

  // Show notification for 80% threshold
  if (total >= _monthlyBudget * 0.8 && total < _monthlyBudget) {
    _notificationService.showBudgetWarningNotification(total, _monthlyBudget);
  }

  // Show notification for exceeded budget
  if (total >= _monthlyBudget) {
    _notificationService.showBudgetExceededNotification(total, _monthlyBudget);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Budget exceeded! Spent ₹${total.toStringAsFixed(0)} / ₹${_monthlyBudget.toStringAsFixed(0)}')),
    );
  }}

  void _setBudgetDialog() {
    if (_currentUser == null) return;
    final c = TextEditingController(text: _monthlyBudget.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Monthly Budget (₹)'),
        content: TextField(
          controller: c,
          decoration: const InputDecoration(
            labelText: 'Budget Amount',
            prefixText: '₹ ',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final v = double.tryParse(c.text.trim());
              if (v != null && v > 0) {
                await _firestoreService.setMonthlyBudget(_currentUser!.uid, v);
                _checkBudgetExceededSnack();
              }
              if (mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addFriend(String name) async {
    if (_currentUser == null) return;
    try {
      await _firestoreService.addFriend(_currentUser!.uid, Friend(id: '', userId: _currentUser!.uid, name: name));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend added successfully')),
        );
      }
    } catch (e) {
      print('Error adding friend: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding friend: $e')),
        );
      }
    }
  }

  void _removeFriend(Friend f) async {
    if (_currentUser == null) return;
    try {
      await _firestoreService.deleteFriend(_currentUser!.uid, f.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend removed')),
        );
      }
    } catch (e) {
      print('Error removing friend: $e');
    }
  }

 void _addExpense(Expense e) async {
      if (_currentUser == null) return;
  try {
    await _firestoreService.addExpense(_currentUser!.uid, e);
    
    // Show expense added notification
    _notificationService.showExpenseAddedNotification(e.title, e.amount);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added successfully')),
      );
    }
  } catch (e) {
    print('Error adding expense: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding expense: $e')),
      );
    }
  }
}

  void _updateExpense(Expense e) async {
    if (_currentUser == null) return;
    try {
      await _firestoreService.updateExpense(_currentUser!.uid, e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense updated')),
        );
      }
    } catch (e) {
      print('Error updating expense: $e');
    }
  }

  void _removeExpense(Expense e) async {
    if (_currentUser == null) return;
    try {
      await _firestoreService.deleteExpense(_currentUser!.uid, e.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense deleted')),
        );
      }
    } catch (e) {
      print('Error deleting expense: $e');
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading your data...'),
            ],
          ),
        ),
      );
    }

    final List<Widget> pages = [
      HomePage(
        expenses: _expenses,
        friends: _friends,
        monthlyBudget: _monthlyBudget,
      ),
      ExpensesPage(
        usdInr: _usdInr,
        expenses: _expenses,
        friends: _friends,
        userId: _currentUser!.uid,
        onCreate: _addExpense,
        onUpdate: _updateExpense,
        onDelete: _removeExpense,
      ),
      FriendsPage(friends: _friends, onAdd: _addFriend, onDelete: _removeFriend),
      AnalyticsPage(expenses: _expenses, friends: _friends),
      SummaryPage(friends: _friends, expenses: _expenses),
      ChatScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Tracker'),
        actions: [
          if (_usdInr > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '\$1 = ₹${_usdInr.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.onToggleTheme(!widget.isDarkMode),
            tooltip: 'Toggle theme',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'budget':
                  _setBudgetDialog();
                  break;
                case 'profile':
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(userId: _currentUser!.uid)));
                  break;
                case 'feedback':
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackForm()));
                  break;
                case 'help':
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpPage()));
                  break;
                case 'signOut':
                  _signOut();
                  break;
              }
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: 'budget', child: Text('Set Monthly Budget')),
              PopupMenuItem(value: 'profile', child: Text('Profile Management')),
              PopupMenuItem(value: 'feedback', child: Text('Feedback')),
              PopupMenuItem(value: 'help', child: Text('Help & Guide')),
              PopupMenuItem(value: 'signOut', child: Text('Sign Out')),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long_rounded), label: 'Expenses'),
          NavigationDestination(icon: Icon(Icons.group_rounded), label: 'Friends'),
          NavigationDestination(icon: Icon(Icons.insights_rounded), label: 'Analytics'),
          NavigationDestination(icon: Icon(Icons.account_balance_rounded), label: 'Summary'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_rounded), label: 'Chatbot'),
        ],
      ),
    );
  }
}