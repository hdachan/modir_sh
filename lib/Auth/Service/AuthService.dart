import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/LoginResult.dart';

class AuthService {
  static final _emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  final supabase = Supabase.instance.client;
  final _emailCache = <String, bool>{};
  static const _timeoutDuration = Duration(seconds: 10);

  Future<bool> validateAndCheckEmail(String email) async {
    email = email.trim().toLowerCase();
    if (email.isEmpty) {
      throw Exception('이메일 주소를 입력하세요.');
    }
    if (email.length > 254) {
      throw Exception('이메일은 254자를 넘을 수 없습니다.');
    }
    if (!_emailRegExp.hasMatch(email)) {
      throw Exception('유효한 이메일 주소를 입력하세요.');
    }

    if (_emailCache.containsKey(email)) {
      if (!_emailCache[email]!) {
        throw Exception('이미 등록된 이메일입니다.');
      }
      return true;
    }

    try {
      final response = await supabase
          .from('userinfo')
          .select('id')
          .eq('email', email)
          .maybeSingle()
          .timeout(_timeoutDuration);

      final isAvailable = response == null;
      _emailCache[email] = isAvailable;
      if (!isAvailable) {
        throw Exception('이미 등록된 이메일입니다.');
      }
      return true;
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception('네트워크가 느립니다.');
      } else if (e is PostgrestException) {
        throw Exception('서버 오류: ${e.message}');
      }
      throw Exception('이메일 확인에 실패했습니다.');
    }
  }

  Future<LoginResult> signIn(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return LoginResult(errorMessage: '이메일과 비밀번호를 모두 입력해주세요.');
    }

    if (!_emailRegExp.hasMatch(email.trim().toLowerCase())) {
      return LoginResult(errorMessage: '올바른 이메일 형식을 입력해주세요.');
    }

    try {
      final response = await supabase.auth
          .signInWithPassword(email: email, password: password)
          .timeout(_timeoutDuration);

      if (response.session != null && !response.session!.isExpired) {
        return LoginResult();
      }
      return LoginResult(errorMessage: '로그인 실패: 사용자 정보를 확인할 수 없습니다.');
    } catch (e) {
      if (e is AuthException) {
        return LoginResult(
          errorMessage: e.message.contains('Invalid login credentials')
              ? '이메일 또는 비밀번호가 잘못되었습니다.'
              : '로그인 오류: ${e.message}',
        );
      } else if (e is TimeoutException) {
        return LoginResult(errorMessage: '네트워크가 느립니다.');
      }
      return LoginResult(errorMessage: '알 수 없는 오류: $e');
    }
  }

  Future<LoginResult> signInWithGoogle() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'https://modir-club.web.app/auth/v1/callback',
      ).timeout(_timeoutDuration);
      return LoginResult();
    } catch (e) {
      if (e is AuthException) {
        return LoginResult(errorMessage: 'Google 로그인 오류: ${e.message}');
      } else if (e is TimeoutException) {
        return LoginResult(errorMessage: '네트워크가 느립니다.');
      }
      return LoginResult(errorMessage: '알 수 없는 오류: $e');
    }
  }
}