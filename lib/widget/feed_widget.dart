import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';




PreferredSizeWidget customAppBar() {
  return PreferredSize(
    preferredSize: const Size.fromHeight(56),
    child: Row(
      children: [
        // SVG 이미지 아이콘
        GestureDetector(
          onTap: () => print("로고 클릭"), // 뒤로가기 대신 로고 클릭 동작
          child: Container(
            padding: const EdgeInsets.all(16), // 기존 패딩 유지
            child: SvgPicture.asset(
              'assets/image/logo_primary.svg',
              width: 24, // 아이콘 크기와 일치
              height: 24,
              fit: BoxFit.contain, // 원본 비율 유지
            ),
          ),
        ),
        const Spacer(),
        // 돋보기 아이콘
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => print("돋보기 버튼 클릭"),
            child: const Icon(
              Icons.search_rounded,
              size: 24,
              color: Colors.black,
            ),
          ),
        ),
        // 종 아이콘
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => print("종 버튼 클릭"),
            child: const Icon(
              Icons.notifications_outlined,
              size: 24,
              color: Colors.black,
            ),
          ),
        ),
        // 저장 아이콘
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => print("저장 버튼 클릭"),
            child: const Icon(
              Icons.bookmark_border,
              size: 24,
              color: Colors.black,
            ),
          ),
        ),
      ],
    ),
  );
}

PreferredSizeWidget customBodyBar(BuildContext context, String title) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(60),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 44,
        decoration: ShapeDecoration(
          color: const Color(0xFFF6F6F6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        padding: EdgeInsets.only(left: 16,right: 8,top: 16,bottom: 16),
        child: Row(
          children: [
            Text(
              '공지',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                height: 1,
                letterSpacing: -0.30,
              ),
            ),
            SizedBox(width: 8),
            Text(
              '모디랑 커뮤니티 이용수칙 안내',
              style: TextStyle(
                color: const Color(0xFF5D5D5D),
                fontSize: 12,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                height: 1,
                letterSpacing: -0.30,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}