import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../utils/SessionManager.dart';
import '../models/WithdrawalReasonModel.dart';
import '../services/WithdrawalService.dart';


class WithdrawalViewModel extends ChangeNotifier {
  final WithdrawalService _service = WithdrawalService();

  final List<String> reasons = [
    '잘 안사용하게 되는 것 같아요',
    '서비스 지연이 너무 심해요',
    '매장 찾는게 불편해요',
    '필요없는 내용이 너무 많아요',
    '기타'
  ];

  Set<int> selectedIndexes = {};
  TextEditingController otherReasonController = TextEditingController();

  void toggleReason(int index) {
    if (selectedIndexes.contains(index)) {
      selectedIndexes.remove(index);
    } else {
      selectedIndexes.add(index);
    }
    notifyListeners();
  }

  Future<void> saveWithdrawalReason(BuildContext context) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      print("사용자가 로그인되어 있지 않습니다.");
      return;
    }

    try {
      if (selectedIndexes.isEmpty) {
        print("하나 이상의 탈퇴 사유를 선택해주세요.");
        return;
      }

      List<String> selectedReasonsList =
      selectedIndexes.map((index) => reasons[index]).toList();

      String? otherText;
      if (selectedIndexes.contains(reasons.length - 1)) {
        // '기타'가 선택됐을 경우
        if (otherReasonController.text.trim().isEmpty) {
          print("기타 사유를 입력해주세요.");
          return;
        }
        otherText = otherReasonController.text.trim();
      }

      // 사유 리스트 생성 (기타는 입력값으로 대체)
      final finalReasons = selectedReasonsList.map((r) => r == '기타' ? otherText! : r).toList();

      // 최종적으로 유효하지 않은 이유(빈 문자열 등)가 있다면 필터링
      if (finalReasons.any((r) => r.trim().isEmpty)) {
        print("빈 사유는 저장할 수 없습니다.");
        return;
      }

      WithdrawalReasonModel withdrawalData = WithdrawalReasonModel(
        userId: user.id,
        reasons: finalReasons,
      );

      await _service.saveWithdrawalReason(withdrawalData);

      // UI 상태 초기화
      selectedIndexes.clear();
      otherReasonController.clear();
      notifyListeners();

      // 로그인 선택 화면으로 이동
      context.go('/login');
    } catch (e) {
      print("탈퇴 사유 저장 중 오류 발생: $e");
    }
  }


}
