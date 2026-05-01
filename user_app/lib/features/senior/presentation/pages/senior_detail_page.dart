import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../di/injection.dart';
import '../../domain/entities/senior.dart';
import '../bloc/vitals_bloc.dart';
import '../widgets/sleep_timeline_card.dart';
import '../widgets/vitals_line_chart_card.dart';

/// 시니어 한 명의 상세 — 24시간 RiskScore / HR / 활동량 / 수면 차트.
class SeniorDetailPage extends StatelessWidget {
  final Senior senior;

  const SeniorDetailPage({super.key, required this.senior});

  @override
  Widget build(BuildContext context) {
    developer.log(
      'SeniorDetailPage build(senior=${senior.id})',
      name: 'CareConnect.UI',
    );
    return BlocProvider<VitalsBloc>(
      create: (_) => sl<VitalsBloc>()..add(VitalsSubscribed(seniorId: senior.id)),
      child: _Scaffold(senior: senior),
    );
  }
}

class _Scaffold extends StatelessWidget {
  final Senior senior;
  const _Scaffold({required this.senior});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${senior.name} · 24시간'),
      ),
      body: BlocBuilder<VitalsBloc, VitalsState>(
        builder: (context, state) {
          return switch (state.status) {
            VitalsStatusUI.initial ||
            VitalsStatusUI.loading =>
              const Center(child: CircularProgressIndicator()),
            VitalsStatusUI.failure => Center(
                child: Text(state.failure?.message ?? '알 수 없는 오류'),
              ),
            VitalsStatusUI.loaded =>
              _ChartsLayout(state: state),
          };
        },
      ),
    );
  }
}

/// 모바일: 세로 스크롤 / 태블릿+: 2열 그리드.
class _ChartsLayout extends StatelessWidget {
  final VitalsState state;
  const _ChartsLayout({required this.state});

  @override
  Widget build(BuildContext context) {
    final cards = _buildCards(state);

    return ResponsiveLayout(
      mobile: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: cards.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) => cards[i],
      ),
      tablet: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.7,
          children: cards,
        ),
      ),
    );
  }

  List<Widget> _buildCards(VitalsState state) {
    return [
      VitalsLineChartCard(
        title: 'RiskScore',
        unit: '점',
        icon: Icons.shield_outlined,
        color: AppColors.statusEmergency,
        samples: state.samples,
        anomalies: state.anomalies,
        extractor: (s) => s.riskScore.value.toDouble(),
        thresholdLines: const [
          (y: 80, label: 'Emergency', color: AppColors.statusEmergency),
          (y: 50, label: 'Warning', color: AppColors.statusWarning),
        ],
      ),
      VitalsLineChartCard(
        title: '심박수',
        unit: 'bpm',
        icon: Icons.favorite_outline,
        color: const Color(0xFFE53935),
        samples: state.samples,
        anomalies: state.anomalies,
        extractor: (s) => s.heartRate?.toDouble(),
        thresholdLines: const [
          (y: 100, label: '높음', color: Color(0xFFE53935)),
          (y: 50, label: '낮음', color: Color(0xFF1E88E5)),
        ],
      ),
      VitalsLineChartCard(
        title: '활동량',
        unit: '/min',
        icon: Icons.directions_walk,
        color: const Color(0xFF2E7D32),
        samples: state.samples,
        anomalies: state.anomalies,
        extractor: (s) => s.activity,
      ),
      SleepTimelineCard(samples: state.samples),
    ];
  }
}
