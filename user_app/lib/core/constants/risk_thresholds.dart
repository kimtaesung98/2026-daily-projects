/// RiskScore (0~100) 에 대한 단일 진실 공급원 (Single Source of Truth).
///
/// 임계값을 변경할 경우 반드시 이곳에서만 수정합니다.
class RiskThresholds {
  /// 일정 시간 활동이 없을 때 진입 (Idle)
  static const int idleMin = 20;

  /// 주의 단계 진입 (Warning)
  static const int warningMin = 50;

  /// 즉시 알림 / 긴급 호출 진입 (Emergency)
  static const int emergencyMin = 80;

  /// 점수 허용 범위
  static const int min = 0;
  static const int max = 100;

  const RiskThresholds._();
}
