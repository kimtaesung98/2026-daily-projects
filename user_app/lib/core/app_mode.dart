/// 앱이 어떤 모드로 부팅됐는지 보관하는 정적 플래그.
///
/// `main()` 부트 시점에 [setDemoMode] 로 한 번만 설정되며,
/// 이후 UI / DI 가 이 값을 읽어 분기 처리합니다.
class AppMode {
  static bool _isDemoMode = false;

  /// Firebase 초기화 실패 등으로 Mock DataSource 가 등록된 상태인지 여부.
  static bool get isDemoMode => _isDemoMode;

  /// 부트 단계에서 한 번만 호출.
  static void setDemoMode(bool value) {
    _isDemoMode = value;
  }

  const AppMode._();
}
