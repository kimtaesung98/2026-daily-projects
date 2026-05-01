import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/risk_score.dart';
import '../../domain/entities/sleep_state.dart';
import '../../domain/entities/vital_sample.dart';

/// Firestore `seniors/{seniorId}/vitals/{autoId}` 문서 매핑.
///
/// 스키마 예:
/// ```
/// recordedAt: timestamp
/// riskScore: number      // 0 ~ 100
/// heartRate: number?     // BPM
/// activity: number?      // 1분당 걸음수 또는 가속도 RMS
/// sleepState: string?    // 'awake' | 'light' | 'rem' | 'deep'
/// ```
class VitalSampleModel {
  final DateTime recordedAt;
  final int riskScore;
  final int? heartRate;
  final double? activity;
  final String? sleepState;

  const VitalSampleModel({
    required this.recordedAt,
    required this.riskScore,
    this.heartRate,
    this.activity,
    this.sleepState,
  });

  factory VitalSampleModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const {};
    return VitalSampleModel(
      recordedAt:
          (data['recordedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      riskScore: (data['riskScore'] as num?)?.toInt() ?? 0,
      heartRate: (data['heartRate'] as num?)?.toInt(),
      activity: (data['activity'] as num?)?.toDouble(),
      sleepState: data['sleepState'] as String?,
    );
  }

  VitalSample toEntity() => VitalSample(
        recordedAt: recordedAt,
        riskScore: RiskScore.clamped(riskScore),
        heartRate: heartRate,
        activity: activity,
        sleepState: SleepState.fromString(sleepState),
      );
}
