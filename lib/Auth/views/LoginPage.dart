import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../widget/login_field.dart';
import '../../widget/login_widget.dart';
import '../ViewModel/AuthViewModel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isChecked = true;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: loginAppBar(
            context,
            "로그인",
            const Color(0xFF000000),
                () => print('완료 버튼 눌림'),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          EmailTextField(controller: viewModel.emailController),
                          const SizedBox(height: 16),
                          PasswordField(controller: viewModel.passwordController),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isChecked = !isChecked;
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                isChecked ? Icons.check_circle : Icons.circle_outlined,
                                color: isChecked ? Colors.black : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '자동 로그인',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isChecked ? Colors.black : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => print("아이디 찾기"),
                              child: const Text(
                                '아이디 찾기',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () => print("비밀번호 찾기"),
                              child: const Text(
                                '비밀번호 찾기',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (viewModel.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(
                          viewModel.errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    bottomBar(
                      buttonText: '로그인',
                      onTap: () async {
                        await viewModel.signIn();
                        if (viewModel.errorMessage == null) {
                          context.go('/community');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (viewModel.isLoading)
          Container(
            color: Colors.black.withOpacity(0.4),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
