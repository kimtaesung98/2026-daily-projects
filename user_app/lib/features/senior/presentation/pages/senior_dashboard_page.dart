import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/app_mode.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../di/injection.dart';
import '../bloc/senior_bloc.dart';
import 'views/senior_dashboard_mobile_view.dart';
import 'views/senior_dashboard_tablet_view.dart';

/// 시니어 대시보드의 진입점 페이지.
///
/// 자기 자신의 [SeniorBloc] 을 BlocProvider 로 제공하고,
/// 화면 폭에 따라 Mobile / Tablet 뷰를 분기합니다.
class SeniorDashboardPage extends StatelessWidget {
  /// 현재 로그인한 보호자의 ID.
  /// 실제 인증 도입 후에는 AuthBloc 로부터 주입됩니다.
  final String guardianId;

  const SeniorDashboardPage({super.key, required this.guardianId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SeniorBloc>(
      create: (_) => sl<SeniorBloc>()
        ..add(SeniorListSubscribed(guardianId)),
      child: const _SeniorDashboardScaffold(),
    );
  }
}

class _SeniorDashboardScaffold extends StatelessWidget {
  const _SeniorDashboardScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Care-Connect'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            tooltip: '알림',
          ),
        ],
        bottom: AppMode.isDemoMode ? const _DemoBanner() : null,
      ),
      body: const ResponsiveLayout(
        mobile: SeniorDashboardMobileView(),
        tablet: SeniorDashboardTabletView(),
      ),
    );
  }
}

/// Firebase 미설정 시 AppBar 하단에 노출되는 안내 배너.
class _DemoBanner extends StatelessWidget implements PreferredSizeWidget {
  const _DemoBanner();

  static const double _height = 36;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _height,
      color: AppColors.statusWarning.withValues(alpha: 0.18),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          const Icon(Icons.info_outline,
              size: 16, color: AppColors.statusWarning),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'DEMO 모드 — Firebase 미설정. flutterfire configure 후 재실행하세요.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
