import 'package:equatable/equatable.dart';

import 'risk_score.dart';
import 'senior_status.dart';

/// 시니어(피보호자) 도메인 엔티티.
///
/// data 계층의 `SeniorModel` 과 분리되어 외부 변경(스키마)에 영향을 받지 않습니다.
class Senior extends Equatable {
  /// 시니어 고유 ID (Firestore document id)
  final String id;

  /// 시니어 이름 (예: "김복순")
  final String name;

  /// 나이
  final int age;

  /// 보호자(가족 구성원) 사용자 ID
  final String guardianId;

  /// 마지막 활동 감지 시각.
  /// `null` 이면 한 번도 데이터가 들어온 적이 없는 것으로 간주.
  final DateTime? lastActiveAt;

  /// 현재 위험 점수 (0~100)
  final RiskScore riskScore;

  const Senior({
    required this.id,
    required this.name,
    required this.age,
    required this.guardianId,
    required this.riskScore,
    this.lastActiveAt,
  });

  /// 위험 점수로부터 도출된 현재 상태.
  SeniorStatus get status => riskScore.status;

  /// 점수만 갱신한 새 인스턴스 반환.
  Senior copyWith({
    String? id,
    String? name,
    int? age,
    String? guardianId,
    DateTime? lastActiveAt,
    RiskScore? riskScore,
  }) =>
      Senior(
        id: id ?? this.id,
        name: name ?? this.name,
        age: age ?? this.age,
        guardianId: guardianId ?? this.guardianId,
        lastActiveAt: lastActiveAt ?? this.lastActiveAt,
        riskScore: riskScore ?? this.riskScore,
      );

  @override
  List<Object?> get props =>
      [id, name, age, guardianId, lastActiveAt, riskScore];
}
