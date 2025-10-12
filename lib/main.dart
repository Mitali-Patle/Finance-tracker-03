//main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme/app_theme.dart';
import 'pages/dashboard_page.dart';
import 'firebase_options.dart';
import 'pages/sign_in_page.dart';
import 'pages/sign_up_page.dart';
import 'services/notification_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().initialize();
  runApp(const FinanceApp());
}

class FinanceApp extends StatefulWidget {
  const FinanceApp({super.key});

  @override
  State<FinanceApp> createState() => _FinanceAppState();
}

class _FinanceAppState extends State<FinanceApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool dark) {
    setState(() {
      _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Finance & Split',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return DashboardPage(
              isDarkMode: _themeMode == ThemeMode.dark,
              onToggleTheme: _toggleTheme,
            );
          }
          return AuthGate(
            onSignInSuccess: () {},
          );
        },
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  final VoidCallback onSignInSuccess;

  const AuthGate({super.key, required this.onSignInSuccess});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showSignInPage = true;

  void _toggleAuthPage() {
    setState(() {
      _showSignInPage = !_showSignInPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSignInPage) {
      return SignInPage(
        onSignInSuccess: widget.onSignInSuccess,
        onGoToSignUp: _toggleAuthPage,
      );
    } else {
      return SignUpPage(
        onSignInSuccess: widget.onSignInSuccess,
        onGoToSignIn: _toggleAuthPage,
      );
    }
  }
}