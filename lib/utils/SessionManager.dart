import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionManager {
  final supabase = Supabase.instance.client;

  void initializeAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) {
      debugPrint('🔍 Auth state changed: ${data.event}');
    });
  }

  Future<bool> isAuthenticated() async {
    try {
      final session = supabase.auth.currentSession;
      final isValid = session != null && !session.isExpired;
      return isValid;
    } catch (e) {
      debugPrint('⚠️ 세션 확인 오류: $e');
      return false;
    }
  }
}