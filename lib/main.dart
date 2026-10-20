import 'package:flutter/material.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation.dart';
import 'services/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ClassCashApp());
}

class ClassCashApp extends StatefulWidget {
  const ClassCashApp({super.key});

  @override
  State<ClassCashApp> createState() => _ClassCashAppState();
}

class _ClassCashAppState extends State<ClassCashApp> {
  bool _isLoggedIn = false;
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final loggedIn = await AuthService.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
      _isCheckingAuth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _isCheckingAuth
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _isLoggedIn
              ? MainNavigationScreen(
                  onLogout: () {
                    setState(() => _isLoggedIn = false);
                  },
                )
              : LoginScreen(
                  onLoginSuccess: () {
                    setState(() => _isLoggedIn = true);
                  },
                ),
    );
  }
}
