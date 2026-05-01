import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/sleep_state.dart';
import '../../domain/entities/vital_sample.dart';

/// 수면 단계 시계열을 가로 막대 타임라인으로 표시.
///
/// 각 인접 샘플 사이를 그 샘플의 [SleepState] 색상으로 채웁니다.
class SleepTimelineCard extends StatelessWidget {
  final List<VitalSample> samples;

  const SleepTimelineCard({super.key, required this.samples});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final usable = samples.where((s) => s.sleepState != SleepState.unknown).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bedtime_outlined,
                    color: theme.colorScheme.primary, size: 18),
                const SizedBox(width: 8),
                Text('수면',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
            const SizedBox(height: 12),
            if (usable.length < 2)
              const SizedBox(
                height: 28,
                child: Center(child: Text('수면 데이터가 부족합니다')),
              )
            else ...[
              SizedBox(height: 28, child: _SleepBar(samples: usable)),
              const SizedBox(height: 8),
              _Axis(samples: usable),
              const SizedBox(height: 12),
              const _Legend(),
            ],
          ],
        ),
      ),
    );
  }
}

class _SleepBar extends StatelessWidget {
  final List<VitalSample> samples;
  const _SleepBar({required this.samples});

  @override
  Widget build(BuildContext context) {
    final start = samples.first.recordedAt;
    final end = samples.last.recordedAt;
    final totalMs = end.difference(start).inMilliseconds.toDouble();

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Row(
        children: [
          for (int i = 0; i < samples.length - 1; i++)
            Expanded(
              flex: () {
                final spanMs = samples[i + 1]
                    .recordedAt
                    .difference(samples[i].recordedAt)
                    .inMilliseconds
                    .toDouble();
                if (totalMs <= 0) return 1;
                // flex 는 정수 — 비율을 정수로 환산.
                return (spanMs / totalMs * 1000).round().clamp(1, 1000);
              }(),
              child: Container(color: samples[i].sleepState.color),
            ),
        ],
      ),
    );
  }
}

class _Axis extends StatelessWidget {
  final List<VitalSample> samples;
  const _Axis({required this.samples});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = DateFormat('HH:mm');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(fmt.format(samples.first.recordedAt),
            style: theme.textTheme.bodySmall),
        Text(fmt.format(samples[samples.length ~/ 2].recordedAt),
            style: theme.textTheme.bodySmall),
        Text(fmt.format(samples.last.recordedAt),
            style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        for (final s in [
          SleepState.awake,
          SleepState.light,
          SleepState.rem,
          SleepState.deep,
        ])
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: s.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(s.label, style: theme.textTheme.bodySmall),
            ],
          ),
      ],
    );
  }
}
