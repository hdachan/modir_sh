import 'package:flutter/material.dart';

import '../../widget/Mypage_widget.dart';
import '../../widget/agree_widget.dart';




class termsScreen extends StatefulWidget {
  @override
  _termsScreenState createState() => _termsScreenState();
}

class _termsScreenState extends State<termsScreen> with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                CustomAppBar(title: '약관', context: context),
                customButton(
                  '모디랑 이용약관',
                      () {
                  },
                ),
                customButton(
                  '개인정보처리방침',
                      () {
                  },
                ),
                customButton(
                  '위치기반서비스 이용약관',
                      () {
                  },
                ),
                customButton(
                  '데이터제공정책',
                      () {
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