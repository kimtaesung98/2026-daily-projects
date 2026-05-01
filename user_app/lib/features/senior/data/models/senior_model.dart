import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/risk_score.dart';
import '../../domain/entities/senior.dart';

/// Firestore 저장 형태와 매핑되는 DTO.
///
/// Firestore 컬렉션 스키마 (제안):
/// ```
/// /seniors/{seniorId}
///   - name: string
///   - age: number
///   - guardianId: string
///   - riskScore: number          // 0~100
///   - lastActiveAt: timestamp?
/// ```
class SeniorModel {
  final String id;
  final String name;
  final int age;
  final String guardianId;
  final int riskScore;
  final DateTime? lastActiveAt;

  const SeniorModel({
    required this.id,
    required this.name,
    required this.age,
    required this.guardianId,
    required this.riskScore,
    this.lastActiveAt,
  });

  factory SeniorModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const {};
    return SeniorModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      age: (data['age'] as num?)?.toInt() ?? 0,
      guardianId: data['guardianId'] as String? ?? '',
      riskScore: (data['riskScore'] as num?)?.toInt() ?? 0,
      lastActiveAt: (data['lastActiveAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, Object?> toFirestore() => {
        'name': name,
        'age': age,
        'guardianId': guardianId,
        'riskScore': riskScore,
        'lastActiveAt':
            lastActiveAt != null ? Timestamp.fromDate(lastActiveAt!) : null,
      };

  /// data → domain 변환.
  Senior toEntity() => Senior(
        id: id,
        name: name,
        age: age,
        guardianId: guardianId,
        riskScore: RiskScore.clamped(riskScore),
        lastActiveAt: lastActiveAt,
      );
}
