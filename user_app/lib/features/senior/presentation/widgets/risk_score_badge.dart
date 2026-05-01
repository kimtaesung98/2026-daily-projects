import 'package:flutter/material.dart';

import '../../domain/entities/risk_score.dart';

/// RiskScore 점수를 색상과 함께 보여주는 작은 칩.
class RiskScoreBadge extends StatelessWidget {
  final RiskScore score;

  const RiskScoreBadge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final color = score.status.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '${score.value}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            score.status.label,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
