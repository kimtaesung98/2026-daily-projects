import 'package:equatable/equatable.dart';

import 'senior_status.dart';

/// 차트 위에 그릴 "이상 구간" 밴드.
///
/// 예) `[10:32 ~ 10:48]` 동안 RiskScore 가 Warning 단계를 유지했음을
/// 차트의 X 축 기간 음영으로 표현하기 위한 도메인 객체.
class AnomalyBand extends Equatable {
  /// 구간 시작 시각.
  final DateTime start;

  /// 구간 종료 시각.
  final DateTime end;

  /// 어떤 단계의 이상인가? (Warning / Emergency 등)
  final SeniorStatus severity;

  const AnomalyBand({
    required this.start,
    required this.end,
    required this.severity,
  });

  Duration get duration => end.difference(start);

  @override
  List<Object?> get props => [start, end, severity];
}
