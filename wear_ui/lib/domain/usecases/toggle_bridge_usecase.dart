import '../../network/sync_service.dart';

/// 브릿지(데이터 수집 및 전송)의 시작/종료 로직을 캡슐화합니다.
class ToggleBridgeUseCase {
  final SyncService _syncService;

  ToggleBridgeUseCase(this._syncService);

  bool execute(bool isCurrentlyStreaming) {
    if (isCurrentlyStreaming) {
      _syncService.stopBridge();
      return false; // 상태를 중지(false)로 반환
    } else {
      _syncService.startBridge();
      return true; // 상태를 실행(true)으로 반환
    }
  }
}