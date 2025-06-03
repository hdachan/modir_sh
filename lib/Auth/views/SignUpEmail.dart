import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widget/login_field.dart';
import '../../widget/login_widget.dart';
import '../ViewModel/AuthViewModel.dart';
import 'SignUpPassword.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      setState(
              () => _isButtonEnabled = _emailController.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _checkEmailAndNavigate(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final email = _emailController.text.trim();

    if (!await authViewModel.validateAndCheckEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authViewModel.errorMessage ?? '오류가 발생했습니다.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PasswordScreen(email: email)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:                    emailAppBar(
        context,
        "모디랑 회원가입",
        const Color(0xFF000000),
            () => print('완료 버튼 눌림'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Signuptext('이메일 입력', '어서오세요 모디랑 입니다.\n로그인을 위해 사용하실 이메일을 입력해주세요.'),
                    EmailTextField(controller: _emailController),
                    SizedBox(height: 300),
                    bottomBar(
                      buttonText: '다음',
                      onTap: _isButtonEnabled
                          ? () => _checkEmailAndNavigate(context)
                          : () {},
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}