// 돟의하기 화면 상단바
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Widget CustomAppBar({required String title, required BuildContext context}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return Container(
        width: double.infinity,
        height: 56,
        color:  Colors.white,
        padding: EdgeInsets.only(
          right: 16,
        ),
        child: Row(
          children: [
            // 뒤로가기 버튼
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(16),
                child: Icon(
                  Icons.chevron_left,
                  size: 24,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              height: 56,
              padding: const EdgeInsets.only(top: 14,bottom: 14),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  height: 1.40,
                  letterSpacing: -0.50,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

//환경설정 상단바
Widget ProfileEditAppBar({required String title, required BuildContext context}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return Container(
        width: double.infinity,
        height: 56,
        color:  Colors.white,
        padding: EdgeInsets.only(
          right: 16,
        ),
        child: Row(
          children: [
            // 뒤로가기 버튼
            GestureDetector(
              onTap: () {
                context.go('/mypage');
              },
              child: Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(16),
                child: Icon(
                  Icons.chevron_left,
                  size: 24,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              height: 56,
              padding: const EdgeInsets.only(top: 14,bottom: 14),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  height: 1.40,
                  letterSpacing: -0.50,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}