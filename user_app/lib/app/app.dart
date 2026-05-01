import 'package:flutter/material.dart';

import '../features/senior/presentation/pages/senior_dashboard_page.dart';
import 'theme/app_theme.dart';

/// 앱 루트 위젯.
///
/// - Material 3 테마 적용 (light / dark 자동 전환)
/// - 임시 진입점: SeniorDashboardPage
///   (실제 라우팅은 추후 go_router 도입 시 `app/router/app_router.dart` 로 이전 예정)
class App extends StatelessWidget {
  const App({super.key});

  /// TODO(team): 인증 도입 후 AuthBloc 으로부터 받아오도록 교체.
  static const String _devGuardianId = 'dev-guardian-001';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Care-Connect',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const SeniorDashboardPage(guardianId: _devGuardianId),
    );
  }
}
