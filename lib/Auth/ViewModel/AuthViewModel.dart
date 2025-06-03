import 'package:flutter/material.dart';
import '../Service/AuthService.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  String? errorMessage;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  AuthViewModel(this._authService);

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> signIn() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      final result = await _authService.signIn(email, password);
      isLoading = false;
      errorMessage = result.errorMessage;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.signInWithGoogle();
      isLoading = false;
      errorMessage = result.errorMessage;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> validateAndCheckEmail(String email) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.validateAndCheckEmail(email);
      isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}