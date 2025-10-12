//profile_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_services.dart';
import '../services/notification_service.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = true;
  String? _currentEmail;
  bool _dailyReminders = false;
  bool _budgetAlerts = true;
  bool _expenseConfirmations = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // [CORRECTED] Added dispose method for controllers to prevent memory leaks.
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // [CORRECTED] Added 'if (mounted)' checks for safety in async operations.
  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final userProfile = await _firestoreService.getUserProfile(widget.userId);
      if (mounted && userProfile != null) {
        setState(() {
          _nameController.text = userProfile['name'] ?? '';
          _emailController.text = userProfile['email'] ?? '';
          _currentEmail = userProfile['email'];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // [CORRECTED] Added 'if (mounted)' checks for safety.
  Future<void> _updateUserProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final String newName = _nameController.text.trim();
      final String newEmail = _emailController.text.trim();

      await _firestoreService.updateUserProfile(widget.userId, {'name': newName});

      if (newEmail != _currentEmail && FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.currentUser!.updateEmail(newEmail);
        await _firestoreService.updateUserProfile(widget.userId, {'email': newEmail});
        _currentEmail = newEmail;
      }
      
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } on FirebaseAuthException catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _changePassword() async {
    final String? email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User email not found.')),
        );
        return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset link sent to $email.')),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send email: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Management')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      child: Icon(Icons.person, size: 80, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _updateUserProfile,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Update Profile', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _changePassword,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Change Password', style: TextStyle(fontSize: 18)),
                  ),
                  // In profile_page.dart, inside the build method's Column, after the "Change Password" button:

const SizedBox(height: 32),
const Divider(),
const SizedBox(height: 16),

// Notification Settings Section
const Text(
  'Notifications',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),
const SizedBox(height: 16),

// Daily Reminders Toggle
SwitchListTile(
  title: const Text('Daily Reminders'),
  subtitle: const Text('Get daily expense tracking reminders'),
  value: _dailyReminders,
  onChanged: (value) {
    setState(() => _dailyReminders = value);
    if (value) {
      NotificationService().scheduleDailyReminder(hour: 20, minute: 0);
    } else {
      NotificationService().cancel(0);
    }
  },
),

// Budget Alerts Toggle
SwitchListTile(
  title: const Text('Budget Alerts'),
  subtitle: const Text('Get notified when approaching budget limit'),
  value: _budgetAlerts,
  onChanged: (value) {
    setState(() => _budgetAlerts = value);
  },
),

// Expense Confirmations Toggle
SwitchListTile(
  title: const Text('Expense Confirmations'),
  subtitle: const Text('Get notified when expenses are added'),
  value: _expenseConfirmations,
  onChanged: (value) {
    setState(() => _expenseConfirmations = value);
  },
),
                ],
              ),
            ),
    );
  }
}