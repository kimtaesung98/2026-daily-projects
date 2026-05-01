import 'dart:math' as math;

import '../../domain/entities/risk_score.dart';
import '../../domain/entities/sleep_state.dart';
import '../../domain/entities/vital_sample.dart';

/// Firestore 에 vitals 데이터가 아직 없을 때, 화면 디버깅을 돕기 위해
/// 24시간 분량의 합성 시계열을 생성한다. (5분 간격)
///
/// 두 곳에서만 사용해야 합니다:
///  - `SeniorRepositoryImpl.watchVitals` 가 빈 결과를 받았을 때 폴백
///  - 단위 테스트에서 차트 렌더 검증할 때
class DemoVitalsGenerator {
  const DemoVitalsGenerator();

  List<VitalSample> generate24h({
    DateTime? endingAt,
    int seed = 42,
  }) {
    final end = endingAt ?? DateTime.now();
    final start = end.subtract(const Duration(hours: 24));
    final rng = math.Random(seed);
    final samples = <VitalSample>[];

    // 5분 간격, 총 288개
    for (int i = 0; i <= 288; i++) {
      final t = start.add(Duration(minutes: 5 * i));
      final hour = t.hour + t.minute / 60.0;

      // ─── HR: 야간(22시~6시) 50–60bpm, 주간 65–80bpm. 가끔 스파이크.
      final isNight = hour >= 22 || hour < 6;
      final hrBase = isNight ? 55 : 72;
      final hr = hrBase + rng.nextInt(8) - 4;
      final hrSpike = rng.nextDouble() < 0.04 ? 25 : 0;

      // ─── Activity: 야간 0~5, 주간 30~120, 식사시간 피크
      final activityBase = isNight ? 2.0 : 60.0;
      final mealBoost = (hour > 11.5 && hour < 13) ||
              (hour > 17.5 && hour < 19)
          ? 40.0
          : 0.0;
      final activity =
          (activityBase + mealBoost + rng.nextDouble() * 20).clamp(0, 200);

      // ─── Sleep: 야간 = deep/light/rem 순환, 주간 = awake
      final SleepState sleep = isNight
          ? switch (i % 5) {
              0 => SleepState.light,
              1 => SleepState.deep,
              2 => SleepState.rem,
              3 => SleepState.deep,
              _ => SleepState.light,
            }
          : SleepState.awake;

      // ─── RiskScore: 기본 10, HR 스파이크 / 활동 급감 시 가산
      var risk = 10 + rng.nextInt(8);
      if (hrSpike > 0) risk += 55;
      if (!isNight && activity < 5) risk += 30;
      // 시연용: 13:00 부근 단발성 emergency
      if (hour > 13 && hour < 13.4) risk += 70;
      risk = risk.clamp(0, 100);

      samples.add(VitalSample(
        recordedAt: t,
        riskScore: RiskScore.clamped(risk),
        heartRate: hr + hrSpike,
        activity: activity.toDouble(),
        sleepState: sleep,
      ));
    }
    return samples;
  }
}
