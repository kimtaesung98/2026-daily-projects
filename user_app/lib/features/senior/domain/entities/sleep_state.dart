import 'package:flutter/material.dart';

/// 수면 단계 — 웨어러블이 보고하는 상태값.
enum SleepState {
  awake,
  light,
  deep,
  rem,
  unknown;

  /// 차트 Y 축 위치 (0 = unknown 가장 아래, 4 = awake 가장 위).
  /// 라인 차트로 표현 시 단계가 시각적으로 위/아래로 이동하도록 매핑.
  double get chartY => switch (this) {
        SleepState.unknown => 0,
        SleepState.deep => 1,
        SleepState.rem => 2,
        SleepState.light => 3,
        SleepState.awake => 4,
      };

  String get label => switch (this) {
        SleepState.awake => '깸',
        SleepState.light => '얕은수면',
        SleepState.rem => 'REM',
        SleepState.deep => '깊은수면',
        SleepState.unknown => '미상',
      };

  Color get color => switch (this) {
        SleepState.awake => const Color(0xFFFFB300),
        SleepState.light => const Color(0xFF7E57C2),
        SleepState.rem => const Color(0xFF42A5F5),
        SleepState.deep => const Color(0xFF1A237E),
        SleepState.unknown => const Color(0xFFBDBDBD),
      };

  static SleepState fromString(String? raw) {
    return switch (raw) {
      'awake' => SleepState.awake,
      'light' => SleepState.light,
      'rem' => SleepState.rem,
      'deep' => SleepState.deep,
      _ => SleepState.unknown,
    };
  }
}
