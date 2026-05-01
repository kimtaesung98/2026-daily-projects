import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/senior_bloc.dart';
import '../../widgets/senior_card.dart';
import '../senior_detail_page.dart';

/// Mobile 용 1열 리스트 레이아웃.
class SeniorDashboardMobileView extends StatelessWidget {
  const SeniorDashboardMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SeniorBloc, SeniorState>(
      builder: (context, state) {
        return switch (state.status) {
          SeniorStatusUI.initial ||
          SeniorStatusUI.loading =>
            const Center(child: CircularProgressIndicator()),
          SeniorStatusUI.failure => _ErrorView(message: state.failure?.message ?? '알 수 없는 오류'),
          SeniorStatusUI.loaded when state.seniors.isEmpty =>
            const _EmptyView(),
          SeniorStatusUI.loaded => ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.seniors.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final senior = state.seniors[index];
                return SeniorCard(
                  senior: senior,
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => SeniorDetailPage(senior: senior),
                    ),
                  ),
                );
              },
            ),
        };
      },
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.elderly,
                size: 64, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              '등록된 시니어가 없습니다',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 56, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
