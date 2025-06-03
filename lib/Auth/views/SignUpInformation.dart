import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widget/Mypage_widget.dart';
import '../../widget/login_field.dart';
import '../../widget/login_widget.dart';
import '../Service/InformationService.dart';
import '../ViewModel/InformationViewModel.dart';



class InformationScreen extends StatelessWidget {
  final String email;
  final String password;

  const InformationScreen({super.key, required this.email, required this.password});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InformationViewModel(InformationService()), // Pass InformationService
      child: Scaffold(
        appBar: emailAppBar(
          context,
          "모디랑 회원가입",
          const Color(0xFF000000),
              () => print('완료 버튼 눌림'),
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Consumer<InformationViewModel>(
                    builder: (context, viewModel, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Signuptext('정보 입력', '활동하실 닉네임과 정보들을 입력해 주세요'),
                          const SizedBox(height: 32),
                          Subtext('닉네임'),
                          EmailTextField(controller: viewModel.nicknameController),
                          const SizedBox(height: 8),
                          const Text(
                            '닉네임은 한영문자 포함 특수문자 _만 사용가능합니다',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Subtext('생년월일'),
                          BirthdateTextField(
                            controller: viewModel.birthdateController,
                            hintText: 'YYYYMMDD 형식으로 입력하세요',
                            onChanged: () => viewModel.notifyListeners(),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            height: 76,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '성별',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Pretendard',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    GenderButton(
                                      label: '남자',
                                      isSelected: viewModel.selectedGenderIndex == 0,
                                      onTap: () => viewModel.onGenderButtonPressed(0),
                                    ),
                                    const SizedBox(width: 16),
                                    GenderButton(
                                      label: '여자',
                                      isSelected: viewModel.selectedGenderIndex == 1,
                                      onTap: () => viewModel.onGenderButtonPressed(1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Subtext('카테고리'),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return buildSelectionButtons(
                                ['빈티지', '아메카지'],
                                viewModel.selectedCategoryIndex,
                                viewModel.onCategoryButtonPressed,
                                constraints,
                              );
                            },
                          ),
                          Consumer<InformationViewModel>(
                            builder: (context, viewModel, child) {
                              return bottomBar(
                                buttonText: '완료',
                                onTap: () async {
                                  final errorMessage = await viewModel.signUp(email, password);
                                  if (errorMessage == null) {
                                    print("완벽");
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(errorMessage)),
                                    );
                                  }
                                },
                              );
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
        ),
      ),
    );
  }
}