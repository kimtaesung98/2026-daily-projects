// RiskScore / SeniorStatus 도메인 단위 테스트.
//
// (UI 위젯 테스트는 Firebase / DI 초기화가 필요하므로 추후 통합 테스트로 분리합니다.)

import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/features/senior/domain/entities/risk_score.dart';
import 'package:user_app/features/senior/domain/entities/senior_status.dart';

void main() {
  group('RiskScore', () {
    test('범위 밖 값을 받으면 ArgumentError', () {
      expect(() => RiskScore(-1), throwsArgumentError);
      expect(() => RiskScore(101), throwsArgumentError);
    });

    test('clamped 는 범위로 자동 보정', () {
      expect(RiskScore.clamped(150).value, 100);
      expect(RiskScore.clamped(-10).value, 0);
    });

    test('normalized 는 0.0 ~ 1.0 사이의 값', () {
      expect(RiskScore(0).normalized, 0.0);
      expect(RiskScore(50).normalized, 0.5);
      expect(RiskScore(100).normalized, 1.0);
    });
  });

  group('SeniorStatus.fromScore', () {
    test('점수 → 상태 매핑', () {
      expect(SeniorStatus.fromScore(0), SeniorStatus.normal);
      expect(SeniorStatus.fromScore(19), SeniorStatus.normal);
      expect(SeniorStatus.fromScore(20), SeniorStatus.idle);
      expect(SeniorStatus.fromScore(50), SeniorStatus.warning);
      expect(SeniorStatus.fromScore(80), SeniorStatus.emergency);
      expect(SeniorStatus.fromScore(100), SeniorStatus.emergency);
    });

    test('Emergency 만 즉각적인 알림 필요', () {
      expect(SeniorStatus.normal.requiresImmediateAction, false);
      expect(SeniorStatus.idle.requiresImmediateAction, false);
      expect(SeniorStatus.warning.requiresImmediateAction, false);
      expect(SeniorStatus.emergency.requiresImmediateAction, true);
    });
  });
}
