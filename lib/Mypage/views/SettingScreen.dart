import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widget/Mypage_widget.dart';
import '../../widget/agree_widget.dart';




class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> with SingleTickerProviderStateMixin {
  bool toggleValue = true;

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    context.go('/login');
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF242424),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            '로그아웃',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w700,
              height: 1.10,
              letterSpacing: -0.45,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '정말 로그아웃 하시겠습니까?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  height: 1.30,
                  letterSpacing: -0.30,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                '취소',
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 12,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  height: 1.30,
                  letterSpacing: -0.30,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                _logout();
              },
              child: Text(
                '확인',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  height: 1.30,
                  letterSpacing: -0.30,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                ProfileEditAppBar(title: '환경설정', context: context),
                middleText('알림설정'),
                middleText('정보'),
                customButton(
                  '이용약관',
                      () {
                    context.go('/mypage/setting/terms');
                  },
                ),
                middleText('기타'),
                customButton(
                  '로그아웃',
                      () => _showLogoutDialog(context),
                ),
                customButton(
                  '탈퇴하기',
                      () {
                    context.go('/mypage/setting/withdrawal_reason');
                  },
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}