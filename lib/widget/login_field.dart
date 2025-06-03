import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';



/// 로그인 선택화면 텍스트
class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '모디랑',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 1.30,
                    letterSpacing: -0.60,
                  ),
                ),
                TextSpan(
                  text: '에서 다양한\n매장 정보를 확인하세요',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 1.30,
                    letterSpacing: -0.60,
                  ),
                ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          const Text(
            '나만의 분위기 , 라이프스타일 , 스타일링에 따라 매장을 추천받아보세요',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
              height: 1.40,
              letterSpacing: -0.35,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}


///로그인 버튼
class CustomLoginButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final Color backgroundColor;
  final Gradient? gradient;
  final BorderSide? borderSide;
  final Color textColor;
  final String fontFamily;
  final double iconSize;
  final VoidCallback? onPressed;

  const CustomLoginButton({
    super.key,
    required this.iconPath,
    required this.label,
    this.backgroundColor = Colors.transparent,
    this.gradient,
    this.borderSide,
    required this.textColor,
    required this.fontFamily,
    this.iconSize = 20,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed ?? () => print('버튼 눌렀습니다'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: borderSide ?? BorderSide.none,
          borderRadius: BorderRadius.circular(6),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: gradient == null ? backgroundColor : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              height: iconSize,
              width: iconSize,
            ),
            Expanded(
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.w500,
                    height: 1.40,
                    letterSpacing: -0.35,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// 비밀번호 입력 필드 위젯
class PasswordField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordField({super.key, required this.controller});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true; // 비밀번호 가림 상태

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.only(left: 16, right: 4),
      child: Center(
        child: TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black, // 텍스트 색상 검은색
          ),
          decoration: InputDecoration(
            hintText: "password",
            hintStyle: const TextStyle(
              fontFamily: 'Pretendard',
              color: Color(0xFF888888),
            ),
            border: InputBorder.none,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF888888),
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText; // 비밀번호 표시 토글
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}


/// 이메일 입력 필드 위젯
class EmailTextField extends StatefulWidget {
  final TextEditingController controller;

  const EmailTextField({super.key, required this.controller});

  @override
  State<EmailTextField> createState() => _EmailTextFieldState();
}

class _EmailTextFieldState extends State<EmailTextField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.only(left: 16, right: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              decoration: const InputDecoration(
                hintText: "email@address.com",
                hintStyle: TextStyle(
                  fontFamily: 'Pretendard',
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          if (widget.controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                widget.controller.clear();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.cancel, size: 24, color: Color(0xFF888888)),
              ),
            ),

        ],
      ),
    );
  }
}


/// 생년월일 입력 필드 위젯
class BirthdateTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onChanged;

  const BirthdateTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
  });

  @override
  State<BirthdateTextField> createState() => _BirthdateTextFieldState();
}

class _BirthdateTextFieldState extends State<BirthdateTextField> {
  String? _errorText;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_formatInput);
  }

  void _formatInput() {
    String text = widget.controller.text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 8) text = text.substring(0, 8);

    String formattedText = _formatDateString(text);
    if (widget.controller.text != formattedText) {
      widget.controller.value = TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }

    _validateInput(formattedText);
  }

  String _formatDateString(String input) {
    if (input.length <= 4) return input;
    if (input.length <= 6) return '${input.substring(0, 4)}-${input.substring(4)}';
    return '${input.substring(0, 4)}-${input.substring(4, 6)}-${input.substring(6, 8)}';
  }

  void _validateInput(String text) {
    if (text.length == 10 && _isValidDateFormat(text)) {
      setState(() => _errorText = null);
    } else {
      setState(() => _errorText = 'YYYY-MM-DD 형식으로 입력하세요');
    }
    if (widget.onChanged != null) widget.onChanged!();
  }

  bool _isValidDateFormat(String text) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) return false;

    final year = int.tryParse(text.substring(0, 4)) ?? 0;
    final month = int.tryParse(text.substring(5, 7)) ?? 0;
    final day = int.tryParse(text.substring(8, 10)) ?? 0;

    if (year < 1900 || year > DateTime.now().year) return false;
    if (month < 1 || month > 12) return false;
    if (day < 1 || day > 31) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.only(left: 16, right: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.hintText,
                    hintStyle: const TextStyle(
                      fontFamily: 'Pretendard',
                      color: Color(0xFF888888),
                      fontWeight: FontWeight.w500,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              if (widget.controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    widget.controller.clear();
                    _validateInput('');
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.cancel, size: 24, color: Color(0xFF888888)),
                  ),
                ),
            ],
          ),
        ),
        if (_errorText != null)
          const SizedBox(height: 4),
        if (_errorText != null)
          Text(
            _errorText!,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              color: Color(0xFFFF4D4D), // 밝은 빨간색
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_formatInput);
    super.dispose();
  }
}



/// 가입하기 텍스트
Widget Signuptext(String title, String subtitle) {
  return Container(
    padding: EdgeInsets.only(top: 48, bottom: 42),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Column 자체를 왼쪽 정렬
      children: [
        SizedBox(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                height: 1.10,
                letterSpacing: -0.45,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              subtitle,
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
                height: 1.3,
                letterSpacing: -0.30,
              ),
            ),
          ),
        ),
      ],
    ),

  );
}

/// 회원가입_서브텍스트
Widget Subtext(String nickname) {
  return Container(
    height: 20,
    alignment: Alignment.centerLeft, // 왼쪽 정렬!
    child: Text(
      nickname,
      textAlign: TextAlign.left, // 텍스트 왼쪽 정렬
      style: TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w500,
        height: 1.40,
        letterSpacing: -0.35,
      ),
    ),
  );
}



/// GenderButton 위젯
class GenderButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const GenderButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 48,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Color(0xFF3D3D3D) // 눌렀을때
                  : Color(0xFFF6F6F6), // 안눌렀을때
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : Color(0xFF888888),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
