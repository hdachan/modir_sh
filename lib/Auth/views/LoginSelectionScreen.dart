import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widget/login_field.dart';
import '../Service/AuthService.dart';
import 'LoginPage.dart';



class LoginSelectionScreen extends StatefulWidget {
  const LoginSelectionScreen({super.key});
  @override
  _LoginSelectionScreenState createState() => _LoginSelectionScreenState();
}

class _LoginSelectionScreenState extends State<LoginSelectionScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Container(
                width: 600,
                color: Colors.white, // 600px 너비에 배경색 적용
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WelcomeHeader(),
                    Container(
                      height: 478,
                      padding: EdgeInsets.only(
                          left: 16, right: 16, top: 254, bottom: 48),
                      child: Column(
                        children: [
                          CustomLoginButton(
                            iconPath: 'assets/image/Google_icon.svg',
                            label: '구글 로그인',
                            backgroundColor: const Color(0xFFF2F2F2),
                            textColor: const Color(0xFF1F1F1F),
                            fontFamily: 'Roboto',
                            onPressed: () async {
                              final authService = AuthService();
                              await authService.signInWithGoogle();
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomLoginButton(
                            iconPath: 'assets/image/mini_logo.svg',
                            label: '이메일로 로그인',
                            gradient: const LinearGradient(
                              begin: Alignment(0.00, 0.00),
                              end: Alignment(1.00, 1.00),
                              colors: [Color(0xFF242424), Color(0x00242424)],
                            ),
                            borderSide: const BorderSide(
                              width: 1,
                              color: Color(0xFF3D3D3D),
                            ),
                            textColor: const Color(0xFF05FFF7),
                            fontFamily: 'Pretendard',
                            iconSize: 12,
                            onPressed: () {
                              print('이메일 로그인 버튼 눌렀습니다');
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 20,
                            child: Text(
                              '아직 회원이 아니예요',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 14,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                height: 1.40,
                                letterSpacing: -0.35,
                              ),
                            ),
                          ),
                          Container(
                            height: 32,
                            child: TextButton(
                              onPressed: () {
                                context.go('/login/agree');
                              },
                              child: const Text(
                                '회원가입',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w500,
                                  height: 1.40,
                                  letterSpacing: -0.30,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 48),
                        ],
                      ),
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

