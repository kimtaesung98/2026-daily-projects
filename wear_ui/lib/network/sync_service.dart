import 'dart:async';
import '../domain/interfaces/i_sensor_service.dart';
import '../domain/interfaces/i_connection_monitor.dart';
import '../domain/interfaces/i_edge_client.dart';
import '../domain/interfaces/i_buffer_manager.dart';
import '../core/types/network_status.dart';

class SyncService {
  final ISensorService _sensorService;
  final IBufferManager _bufferManager;
  final IConnectionMonitor _connectionMonitor;
  final IEdgeClient _edgeClient;

  StreamSubscription? _sensorSub;
  
  NetworkStatus _currentNetworkStatus = NetworkStatus.offline;
  bool _isBridgeRunning = false;
  int _retryCount = 0;
  int _totalSentPackets = 0;
  int _lastBatchSentCount = 0;
  final StreamController<Map<String, dynamic>> _runtimeStatusController =
      StreamController<Map<String, dynamic>>.broadcast();

  SyncService(
    this._sensorService,
    this._bufferManager,
    this._connectionMonitor,
    this._edgeClient,
  ) {
    _initNetworkMonitoring();
  }

  void _initNetworkMonitoring() {
    _connectionMonitor.statusStream.listen((status) {
      _currentNetworkStatus = status;
      _emitRuntimeStatus();
      if (status == NetworkStatus.online) {
        _flushBufferToEdge();
      }
    });
  }

  void startBridge() {
    if (_isBridgeRunning) return;
    _isBridgeRunning = true;
    _sensorService.startStreaming();
    _sensorSub = _sensorService.sensorStream.listen((packet) {
      // Tag packet with current known network state
      final updatedPacket = packet.copyWith(networkStatus: _currentNetworkStatus);
      
      _bufferManager.addPacket(updatedPacket);
      _emitRuntimeStatus();

      // If online, immediately flush buffer (which includes the packet just added)
      if (_currentNetworkStatus == NetworkStatus.online) {
         _flushBufferToEdge();
      }
    });
    _emitRuntimeStatus();
  }

  Stream<Map<String, dynamic>> get runtimeStatusStream =>
      _runtimeStatusController.stream;
  NetworkStatus get currentNetworkStatus => _currentNetworkStatus;
  int get retryCount => _retryCount;
  int get totalSentPackets => _totalSentPackets;
  int get lastBatchSentCount => _lastBatchSentCount;
  bool get isBridgeRunning => _isBridgeRunning;

  void _emitRuntimeStatus() {
    _runtimeStatusController.add({
      'networkStatus': _currentNetworkStatus.name,
      'retryCount': _retryCount,
      'totalSentPackets': _totalSentPackets,
      'lastBatchSentCount': _lastBatchSentCount,
      'isBridgeRunning': _isBridgeRunning,
      'bufferSize': _bufferManager.currentSize,
    });
  }

  Future<void> _flushBufferToEdge() async {
    if (_currentNetworkStatus != NetworkStatus.online) return;
    
    final packets = await _bufferManager.flushAndGetPackets();
    if (packets.isEmpty) return;

    try {
      // 전송 시도
      await _edgeClient.sendBatch(packets);
      
      // 성공 시: 재시도 횟수 초기화 및 성공 로그
      _retryCount = 0;
      _lastBatchSentCount = packets.length;
      _totalSentPackets += packets.length;
      _emitRuntimeStatus();
      print("🎯 [Sync]: ${packets.length}개 패킷 전송 완료 및 확인됨.");
      
    } catch (e) {
      _retryCount++;
      _emitRuntimeStatus();
      print("⚠️ [Sync]: 전송 실패 ($_retryCount회). 재시도 대기 중...");
      
      // 실패한 데이터를 다시 버퍼의 '맨 앞'에 복구
      // (순서 유지를 위해 list를 거꾸로 순회하며 앞쪽으로 삽입하는 로직 권장)
      for (var p in packets.reversed) {
        _bufferManager.addPacket(p);
      }

      // 지수 백오프: 실패 횟수가 늘어날수록 다음 재시도까지의 시간을 늘려 시스템 부하 방지
      final backoffSeconds = (1 << _retryCount).clamp(1, 60);
      final backoffDuration = Duration(seconds: backoffSeconds);
      await Future.delayed(backoffDuration);
      
      // 연결 상태가 여전히 온라인이면 재시도 트리거
      if (_currentNetworkStatus == NetworkStatus.online) {
        _flushBufferToEdge();
      }
    }
  }

  void stopBridge() {
    _isBridgeRunning = false;
    _sensorSub?.cancel();
    _sensorSub = null;
    _sensorService.stopStreaming();
    _emitRuntimeStatus();
  }
  
}