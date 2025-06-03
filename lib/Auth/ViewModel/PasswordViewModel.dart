import 'package:flutter/material.dart';

import '../views/SignUpInformation.dart';



class PasswordViewModel extends ChangeNotifier {
  String _password = '';
  String _confirmPassword = '';
  String? _errorMessage;

  String get password => _password;
  String get confirmPassword => _confirmPassword;
  String? get errorMessage => _errorMessage;

  void updatePassword(String value) {
    _password = value;
    _errorMessage = validatePasswords();
    notifyListeners();
  }

  void updateConfirmPassword(String value) {
    _confirmPassword = value;
    _errorMessage = validatePasswords();
    notifyListeners();
  }

  bool hasCombination() =>
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#\$%^&*])').hasMatch(_password);

  bool isLongEnough() => _password.length >= 8;

  bool hasNoConsecutiveChars() {
    for (int i = 0; i < _password.length - 2; i++) {
      if (_password[i] == _password[i + 1] &&
          _password[i] == _password[i + 2]) return false;
    }
    return true;
  }

  bool passwordsMatch() => _password == _confirmPassword && _password.isNotEmpty;

  bool get hasUpperLowerNumberSpecial => hasCombination();
  bool get isLengthValid => isLongEnough();
  bool get noSequentialChars => hasNoConsecutiveChars();
  bool get isPasswordValid => hasCombination() && isLongEnough() && hasNoConsecutiveChars();
  bool get isConfirmPasswordValid => passwordsMatch();

  String? validatePasswords() {
    if (_password.isEmpty || _confirmPassword.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    if (!passwordsMatch()) {
      return '비밀번호가 일치하지 않습니다';
    }
    if (!hasCombination()) {
      return '영문, 숫자, 특수문자를 포함해야 합니다';
    }
    if (!isLongEnough()) {
      return '비밀번호는 8자 이상이어야 합니다';
    }
    if (!hasNoConsecutiveChars()) {
      return '같은 문자를 연속으로 3번 이상 사용할 수 없습니다';
    }
    return null;
  }

  void navigateToNextScreen({
    required String email,
    required BuildContext context,
  }) {
    final error = validatePasswords();
    if (error != null) {
      _errorMessage = error;
      notifyListeners();
      return;
    }

    _errorMessage = null;
    notifyListeners();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InformationScreen(
          email: email,
          password: _password,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
