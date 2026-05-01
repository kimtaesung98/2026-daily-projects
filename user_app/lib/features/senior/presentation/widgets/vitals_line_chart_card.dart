import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/anomaly_band.dart';
import '../../domain/entities/senior_status.dart';
import '../../domain/entities/vital_sample.dart';

/// VitalSample 시계열에서 한 가지 지표를 골라 보여주는 LineChart 카드.
///
/// 이상 구간([AnomalyBand]) 은 차트 X 축에 [VerticalRangeAnnotation] 으로 음영 처리됩니다.
class VitalsLineChartCard extends StatelessWidget {
  final String title;
  final String unit;
  final IconData icon;
  final Color color;

  /// 각 샘플로부터 Y 값을 추출. null 반환 시 해당 샘플은 라인에 포함되지 않습니다.
  final double? Function(VitalSample sample) extractor;

  /// 차트 위에 그릴 가로 임계선들 (예: HR 정상범위 상한). 비워두면 그리지 않음.
  final List<({double y, String label, Color color})> thresholdLines;

  /// 표시할 데이터.
  final List<VitalSample> samples;

  /// 이상 구간(여러 개).
  final List<AnomalyBand> anomalies;

  const VitalsLineChartCard({
    super.key,
    required this.title,
    required this.unit,
    required this.icon,
    required this.color,
    required this.extractor,
    required this.samples,
    this.anomalies = const [],
    this.thresholdLines = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (samples.isEmpty) {
      return _Card(
        title: title,
        icon: icon,
        color: color,
        child: const SizedBox(
          height: 160,
          child: Center(child: Text('표시할 데이터가 없습니다')),
        ),
      );
    }

    // X축 = epoch ms (double), Y축 = 지표 값.
    final spots = <FlSpot>[];
    for (final s in samples) {
      final y = extractor(s);
      if (y == null) continue;
      spots.add(FlSpot(
        s.recordedAt.millisecondsSinceEpoch.toDouble(),
        y,
      ));
    }

    if (spots.isEmpty) {
      return _Card(
        title: title,
        icon: icon,
        color: color,
        child: const SizedBox(
          height: 160,
          child: Center(child: Text('이 지표는 이번 구간에 측정되지 않았습니다')),
        ),
      );
    }

    final minX = spots.first.x;
    final maxX = spots.last.x;
    final ys = spots.map((e) => e.y);
    final minY = ys.reduce((a, b) => a < b ? a : b);
    final maxY = ys.reduce((a, b) => a > b ? a : b);
    final yPadding = (maxY - minY).abs() * 0.15 + 1;

    return _Card(
      title: title,
      icon: icon,
      color: color,
      trailing: Text(
        '${spots.last.y.toStringAsFixed(0)} $unit',
        style: theme.textTheme.titleMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: SizedBox(
        height: 180,
        child: LineChart(
          LineChartData(
            minX: minX,
            maxX: maxX,
            minY: minY - yPadding,
            maxY: maxY + yPadding,
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touched) => touched
                    .map(
                      (spot) => LineTooltipItem(
                        '${DateFormat('HH:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()),
                        )}\n${spot.y.toStringAsFixed(0)} $unit',
                        TextStyle(color: color, fontWeight: FontWeight.w600),
                      ),
                    )
                    .toList(),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(
                color: theme.colorScheme.outlineVariant,
                strokeWidth: 0.5,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (value, meta) => Text(
                    value.toStringAsFixed(0),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  interval: (maxX - minX) / 4,
                  getTitlesWidget: (value, meta) {
                    final t = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        DateFormat('HH:mm').format(t),
                        style: theme.textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ),
            ),
            // 가로 임계선
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                for (final tl in thresholdLines)
                  HorizontalLine(
                    y: tl.y,
                    color: tl.color.withValues(alpha: 0.6),
                    strokeWidth: 1,
                    dashArray: const [4, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      style: TextStyle(
                        color: tl.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      labelResolver: (_) => tl.label,
                    ),
                  ),
              ],
            ),
            // 이상 구간 음영
            rangeAnnotations: RangeAnnotations(
              verticalRangeAnnotations: [
                for (final band in anomalies)
                  VerticalRangeAnnotation(
                    x1: band.start.millisecondsSinceEpoch.toDouble(),
                    x2: band.end.millisecondsSinceEpoch.toDouble(),
                    color: _bandColor(band.severity).withValues(alpha: 0.18),
                  ),
              ],
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                color: color,
                barWidth: 2.2,
                isCurved: true,
                preventCurveOverShooting: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: color.withValues(alpha: 0.10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _bandColor(SeniorStatus s) => switch (s) {
        SeniorStatus.warning => const Color(0xFFF9A825),
        SeniorStatus.emergency => const Color(0xFFD32F2F),
        _ => const Color(0xFF9E9E9E),
      };
}

class _Card extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget? trailing;
  final Widget child;

  const _Card({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                const Spacer(),
                if (trailing case final t?) t,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
