import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/senior_bloc.dart';
import '../../widgets/senior_card.dart';
import '../senior_detail_page.dart';

/// Tablet / Desktop 용 2열(좌측 리스트 + 우측 디테일 placeholder) 레이아웃.
class SeniorDashboardTabletView extends StatelessWidget {
  const SeniorDashboardTabletView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SeniorBloc, SeniorState>(
      builder: (context, state) {
        if (state.status == SeniorStatusUI.loading ||
            state.status == SeniorStatusUI.initial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == SeniorStatusUI.failure) {
          return Center(
            child: Text(state.failure?.message ?? '알 수 없는 오류'),
          );
        }
        if (state.seniors.isEmpty) {
          return const Center(child: Text('등록된 시니어가 없습니다'));
        }

        // 가용 폭에 따라 그리드 컬럼 수 자동 조절.
        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 1100 ? 3 : 2;
            return GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                mainAxisExtent: 168,
              ),
              itemCount: state.seniors.length,
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
            );
          },
        );
      },
    );
  }
}
