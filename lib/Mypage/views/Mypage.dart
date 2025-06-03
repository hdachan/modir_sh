import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widget/Mypage_widget.dart';
import '../viewmodels/ProfileViewModel.dart';
import 'ProfileEditScreen.dart';


class MyPageScreen extends StatefulWidget {
  const MyPageScreen({Key? key}) : super(key: key);

  @override
  _stateMyPageScreen createState() => _stateMyPageScreen();
}

class _stateMyPageScreen extends State<MyPageScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Provider.of<ProfileViewModel>(context, listen: false).fetchUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Consumer<ProfileViewModel>(
                builder: (context, profileVM, child) {
                  return Column(
                    children: [
                      PreferredSize(
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
                                onTap: () {
                                  context.go('/mypage/setting');
                                },
                                child: const Icon(
                                  Icons.settings_outlined,
                                  size: 24,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Container(
                          width: double.infinity,
                          height: 132,
                          padding: const EdgeInsets.only(top: 24, bottom: 24, left: 16, right: 16),
                          child: Container(
                            width: double.infinity,
                            height: 84,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFF6F6F6),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: const Color(0xFFE7E7E7),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            padding: const EdgeInsets.only(left: 16,right: 16,top: 8,bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: ShapeDecoration(
                                    color: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    height: 48,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 28,
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                height: 28,
                                                child: Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Text(
                                                    profileVM.nicknameController.text.isNotEmpty
                                                        ? profileVM.nicknameController.text
                                                        : '모디랑님',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontFamily: 'Pretendard',
                                                      fontWeight: FontWeight.w700,
                                                      height: 1.40,
                                                      letterSpacing: -0.35,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Spacer(),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => ProfileEditScreen()),
                                                  );
                                                },

                                                style: TextButton.styleFrom(
                                                  padding: EdgeInsets.zero, // 내부 패딩 제거
                                                  minimumSize: Size.zero, // 최소 사이즈 제거
                                                ),
                                                child: Container(
                                                  height: 28,
                                                  padding: const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 4),
                                                  decoration: ShapeDecoration(
                                                    color: const Color(0xFF888888),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      '수정',
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
                                                ),
                                              )

                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Container(
                                          height: 16,
                                          child:Row(
                                            children: [
                                              Text(
                                                '큐레이션 로그 알아보기',
                                                style: TextStyle(
                                                  color: const Color(0xFF888888),
                                                  fontSize: 12,
                                                  fontFamily: 'Pretendard',
                                                  fontWeight: FontWeight.w400,
                                                  height: 1.30,
                                                  letterSpacing: -0.30,
                                                ),
                                              ),
                                              SizedBox(width: 2),
                                              Container(
                                                width: 20,
                                                height: 20,
                                                child: Icon(
                                                  Icons.arrow_forward_ios, // 원하는 화살표 아이콘 (예: arrow_forward)
                                                  size: 12, // 아이콘 크기 조정 (Container 크기에 맞게)
                                                  color: const Color(0xFF888888),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      middleText('관심'),
                      customButton(
                        '관심 매장',
                            () {
                          context.go('/mypage/LikedFeed');
                        },
                      ),
                      middleText('문의'),
                      customButton(
                        '사장님들 입점 문의하기!',
                            () async {
                          final Uri url = Uri.parse('https://forms.gle/hrkbBsHA5BphXiN77');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          } else {
                            print('Could not launch $url');
                          }
                        },
                      ),
                      middleText('센터'),
                      customButton(
                        '공지사항',
                            () {
                        },
                      ),
                      customButton(
                        '1:1 문의하기',
                            () async {
                          final Uri url = Uri.parse('https://forms.gle/RfZyztPDJKZX4hnt7');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          } else {
                            print('Could not launch $url');
                          }
                        },
                      ),
                      customButton(
                        '버전',
                            () {
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
