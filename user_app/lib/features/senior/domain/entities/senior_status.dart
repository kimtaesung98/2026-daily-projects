import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/risk_thresholds.dart';

/// 시니어의 현재 상태.
///
/// RiskScore (0~100) 와 1:1 매핑됩니다.
/// - `< idleMin`        → [SeniorStatus.normal]
/// - `< warningMin`     → [SeniorStatus.idle]
/// - `< emergencyMin`   → [SeniorStatus.warning]
/// - `>= emergencyMin`  → [SeniorStatus.emergency]
enum SeniorStatus {
  normal,
  idle,
  warning,
  emergency;

  /// RiskScore 값으로부터 [SeniorStatus] 를 도출합니다.
  static SeniorStatus fromScore(int score) {
    if (score >= RiskThresholds.emergencyMin) return SeniorStatus.emergency;
    if (score >= RiskThresholds.warningMin) return SeniorStatus.warning;
    if (score >= RiskThresholds.idleMin) return SeniorStatus.idle;
    return SeniorStatus.normal;
  }

  /// 상태별 시맨틱 컬러.
  Color get color => switch (this) {
        SeniorStatus.normal => AppColors.statusNormal,
        SeniorStatus.idle => AppColors.statusIdle,
        SeniorStatus.warning => AppColors.statusWarning,
        SeniorStatus.emergency => AppColors.statusEmergency,
      };

  /// 한국어 라벨 (i18n 도입 시 ARB 로 이전).
  String get label => switch (this) {
        SeniorStatus.normal => '정상',
        SeniorStatus.idle => '활동 없음',
        SeniorStatus.warning => '주의',
        SeniorStatus.emergency => '긴급',
      };

  /// 즉각적인 알림이 필요한 상태인지 여부.
  bool get requiresImmediateAction => this == SeniorStatus.emergency;
}
