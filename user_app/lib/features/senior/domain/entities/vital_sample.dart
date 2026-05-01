import 'package:equatable/equatable.dart';

import 'risk_score.dart';
import 'sleep_state.dart';

/// 시니어로부터 한 시점에 수집된 바이탈 스냅샷.
///
/// Firestore 서브컬렉션 `seniors/{seniorId}/vitals/{autoId}` 에 저장됩니다.
class VitalSample extends Equatable {
  /// 측정 시각 (UTC 권장)
  final DateTime recordedAt;

  /// 위험 점수 (0~100). 측정 시점에 산출된 값.
  final RiskScore riskScore;

  /// 심박수 (BPM). 미측정 시 null.
  final int? heartRate;

  /// 1분당 걸음수 (또는 가속도 RMS) — 활동량 지표. 미측정 시 null.
  final double? activity;

  /// 수면 단계.
  final SleepState sleepState;

  const VitalSample({
    required this.recordedAt,
    required this.riskScore,
    this.heartRate,
    this.activity,
    this.sleepState = SleepState.unknown,
  });

  @override
  List<Object?> get props =>
      [recordedAt, riskScore, heartRate, activity, sleepState];
}
