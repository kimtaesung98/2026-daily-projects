import 'package:equatable/equatable.dart';

import '../../../../core/constants/risk_thresholds.dart';
import 'senior_status.dart';

/// 0 ~ 100 사이의 위험 점수를 표현하는 Value Object.
///
/// - 생성 시 범위(0~100)를 강제하므로 [Senior] 객체 어디서든 안전하게 사용 가능합니다.
/// - 점수와 [SeniorStatus] 는 항상 동기화됩니다.
class RiskScore extends Equatable {
  /// 0 (가장 안전) ~ 100 (가장 위험)
  final int value;

  const RiskScore._(this.value);

  /// 안전한 생성 — 범위를 벗어나면 [ArgumentError] 가 throw 됩니다.
  factory RiskScore(int value) {
    if (value < RiskThresholds.min || value > RiskThresholds.max) {
      throw ArgumentError.value(
        value,
        'value',
        'RiskScore must be between ${RiskThresholds.min} and ${RiskThresholds.max}',
      );
    }
    return RiskScore._(value);
  }

  /// 범위 밖의 값을 받았을 때 자동으로 clamp 하여 생성.
  factory RiskScore.clamped(int value) =>
      RiskScore._(value.clamp(RiskThresholds.min, RiskThresholds.max));

  /// RiskScore 0 (Normal) 인스턴스.
  static const RiskScore zero = RiskScore._(0);

  /// 현재 점수에 매핑되는 [SeniorStatus].
  SeniorStatus get status => SeniorStatus.fromScore(value);

  /// 0.0 ~ 1.0 사이의 정규화 값 — Progress 게이지용.
  double get normalized => value / RiskThresholds.max;

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'RiskScore($value, ${status.name})';
}
