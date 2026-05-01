import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/senior.dart';
import '../../domain/entities/senior_status.dart';
import 'risk_score_badge.dart';

/// 시니어 1인의 요약 카드.
///
/// - 이름 / 나이
/// - RiskScore 배지
/// - 마지막 활동 시각 (상대적 표현)
/// - Emergency 시 강조 테두리
class SeniorCard extends StatelessWidget {
  final Senior senior;
  final VoidCallback? onTap;

  const SeniorCard({super.key, required this.senior, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEmergency = senior.status == SeniorStatus.emergency;
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isEmergency
              ? senior.status.color
              : theme.colorScheme.outlineVariant,
          width: isEmergency ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: senior.status.color.withValues(alpha: 0.14),
                    child: Icon(
                      Icons.person_rounded,
                      color: senior.status.color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          senior.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${senior.age}세',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RiskScoreBadge(score: senior.riskScore),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: senior.riskScore.normalized,
                color: senior.status.color,
                backgroundColor: senior.status.color.withValues(alpha: 0.12),
                minHeight: 6,
                borderRadius: BorderRadius.circular(999),
              ),
              const SizedBox(height: 8),
              Text(
                senior.lastActiveAt != null
                    ? '최근 활동: ${_formatTime(senior.lastActiveAt!)}'
                    : '최근 활동 기록 없음',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime t) =>
      DateFormat('yyyy-MM-dd HH:mm').format(t.toLocal());
}
