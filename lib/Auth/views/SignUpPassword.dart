import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../widget/login_field.dart';
import '../../widget/login_widget.dart';
import '../ViewModel/PasswordViewModel.dart';



class PasswordScreen extends StatefulWidget {
  final String email;

  const PasswordScreen({required this.email, super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final PasswordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PasswordViewModel();

    _passwordController.addListener(() {
      _viewModel.updatePassword(_passwordController.text);
      setState(() {});
    });
    _confirmPasswordController.addListener(() {
      _viewModel.updateConfirmPassword(_confirmPasswordController.text);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    _viewModel.navigateToNextScreen(
      email: widget.email,
      context: context,
    );

    if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_viewModel.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allValid = _viewModel.isPasswordValid && _viewModel.isConfirmPasswordValid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: emailAppBar(
        context,
        "모디랑 회원가입",
        Colors.black,
        _handleSubmit,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Signuptext('비밀번호 입력', '계정 생성을 위해 비밀번호를 입력해주세요'),
                    const SizedBox(height: 16),
                    PasswordField(controller: _passwordController),
                    const SizedBox(height: 16),
                    RuleBox(viewModel: _viewModel),
                    const SizedBox(height: 16),
                    PasswordField(
                      controller: _confirmPasswordController,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(height: 16),
                    bottomBar(
                        buttonText: '다음',
                        onTap: _handleSubmit
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


class RuleBox extends StatelessWidget {
  final PasswordViewModel viewModel;

  const RuleBox({super.key, required this.viewModel});

  Widget buildRuleRow(String text, bool isValid) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            color: isValid ? Colors.black : const Color(0xFF888888),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Icon(
          Icons.check,
          color: isValid ? const Color(0xFF05FFF7) : const Color(0xFFCCCCCC),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 138,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          buildRuleRow('영문, 숫자, 특수문자 조합하기', viewModel.hasUpperLowerNumberSpecial),
          const SizedBox(height: 16),
          buildRuleRow('8자 이상 입력하기', viewModel.isLengthValid),
          const SizedBox(height: 16),
          buildRuleRow('연속된 문자 사용하지 않기', viewModel.noSequentialChars),
        ],
      ),
    );
  }
}

class BottomSubmitButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onPressed;

  const BottomSubmitButton({super.key, required this.isEnabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: isEnabled ? const Color(0xFF05FFF7) : const Color(0xFFCCCCCC),
          foregroundColor: Colors.black,
          disabledBackgroundColor: const Color(0xFFEEEEEE),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          '다음',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
