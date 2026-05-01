import 'package:flutter/widgets.dart';

/// 반응형 레이아웃 분기 기준 (Material 3 breakpoint 가이드 참고).
///
/// - `< 600`     : Compact   (Phone)
/// - `600 ~ 840` : Medium    (Foldable / Small Tablet)
/// - `>= 840`    : Expanded  (Tablet / Desktop)
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 840;

  const Breakpoints._();
}

/// `LayoutBuilder` 와 함께 사용하기 위한 화면 크기 enum.
enum ScreenType { mobile, tablet, desktop }

/// 현재 [BoxConstraints] 의 가용 폭으로부터 [ScreenType] 을 추출합니다.
ScreenType screenTypeOf(BoxConstraints constraints) {
  final w = constraints.maxWidth;
  if (w < Breakpoints.mobile) return ScreenType.mobile;
  if (w < Breakpoints.tablet) return ScreenType.tablet;
  return ScreenType.desktop;
}

/// Mobile / Tablet / Desktop 위젯을 한 번에 분기시키는 헬퍼.
///
/// 예)
/// ```dart
/// ResponsiveLayout(
///   mobile: SeniorDashboardMobileView(),
///   tablet: SeniorDashboardTabletView(),
/// )
/// ```
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return switch (screenTypeOf(constraints)) {
          ScreenType.mobile => mobile,
          ScreenType.tablet => tablet ?? mobile,
          ScreenType.desktop => desktop ?? tablet ?? mobile,
        };
      },
    );
  }
}
