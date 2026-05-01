import 'dart:developer' as developer;

import 'entities/anomaly_band.dart';
import 'entities/senior_status.dart';
import 'entities/vital_sample.dart';

/// 시계열 [VitalSample] 로부터 같은 [SeniorStatus] 가 연속되는 구간을
/// 묶어 [AnomalyBand] 리스트를 만들어줍니다.
///
/// 차트 X 축 위에 음영(RangeAnnotation)으로 그릴 때 사용합니다.
class AnomalyDetector {
  const AnomalyDetector();

  /// [SeniorStatus.warning] 또는 [SeniorStatus.emergency] 이상인 연속 구간만 추출.
  List<AnomalyBand> detect(List<VitalSample> samples) {
    developer.log(
      'detect() called with ${samples.length} samples',
      name: 'CareConnect.AnomalyDetector',
    );
    if (samples.isEmpty) return const [];

    // 시간 오름차순 정렬은 호출 측에서 보장한다고 가정하지 않고 안전하게 정렬.
    final sorted = [...samples]
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    final bands = <AnomalyBand>[];
    DateTime? bandStart;
    SeniorStatus? bandStatus;
    DateTime? lastAt;

    // 클로저가 mutable nullable 을 캡처하면 promotion 이 안 되므로
    // 인자 전달 방식으로 작성하여 컴파일러가 non-null 로 인식하도록 한다.
    void flush(DateTime? bandStart, SeniorStatus? bandStatus, DateTime? lastAt) {
      if (bandStart != null && bandStatus != null && lastAt != null) {
        bands.add(AnomalyBand(
          start: bandStart,
          end: lastAt,
          severity: bandStatus,
        ));
      }
    }

    for (final s in sorted) {
      final st = s.riskScore.status;
      final isAnomaly =
          st == SeniorStatus.warning || st == SeniorStatus.emergency;

      if (isAnomaly) {
        if (bandStatus == null || bandStatus != st) {
          flush(bandStart, bandStatus, lastAt);
          bandStart = s.recordedAt;
          bandStatus = st;
        }
        lastAt = s.recordedAt;
      } else {
        flush(bandStart, bandStatus, lastAt);
        bandStart = null;
        bandStatus = null;
        lastAt = s.recordedAt;
      }
    }
    flush(bandStart, bandStatus, lastAt);

    developer.log(
      'detected ${bands.length} anomaly band(s)',
      name: 'CareConnect.AnomalyDetector',
    );
    return bands;
  }
}
