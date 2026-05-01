import 'package:flutter/material.dart';

/// Smart Care-Connect 의 시맨틱 컬러 팔레트.
///
/// Status / RiskScore 단계와 1:1 로 매핑되어 UI 전반에서 재사용됩니다.
class AppColors {
  /// 시드 컬러 — Material 3 ColorScheme.fromSeed 기반.
  static const Color seed = Color(0xFF2E6BE6);

  // ─── 상태 색상 (Status semantic colors) ──────────────────────────────────
  /// Normal — 안정적인 상태
  static const Color statusNormal = Color(0xFF2E7D32);

  /// Idle — 일정 시간 활동 없음 (요주의)
  static const Color statusIdle = Color(0xFF9E9E9E);

  /// Warning — 주의 단계 (RiskScore 50 이상)
  static const Color statusWarning = Color(0xFFF9A825);

  /// Emergency — 긴급 호출 단계 (RiskScore 80 이상)
  static const Color statusEmergency = Color(0xFFD32F2F);

  const AppColors._();
}
