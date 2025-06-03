import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/SessionManager.dart';

class AuthCheckScreen extends StatelessWidget {
  const AuthCheckScreen({super.key});

  Future<void> _checkAuthStatus(BuildContext context) async {
    final sessionManager = SessionManager();
    final isAuthenticated = await sessionManager.isAuthenticated();
    if (context.mounted) {
      context.go(isAuthenticated ? '/community' : '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkAuthStatus(context);
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'modirApp',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}