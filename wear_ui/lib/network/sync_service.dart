import 'dart:async';
import '../domain/interfaces/i_sensor_service.dart';
import '../domain/interfaces/i_connection_monitor.dart';
import '../domain/interfaces/i_edge_client.dart';
import '../domain/interfaces/i_buffer_manager.dart';
import '../core/types/network_status.dart';
import '../core/policy/transmission_policy.dart';

class SyncService {
  final ISensorService _sensorService;
  final IBufferManager _bufferManager;
  final IConnectionMonitor _connectionMonitor;
  final IEdgeClient _edgeClient;
  final TransmissionPolicy _policy;

  StreamSubscription? _sensorSub;
  Timer? _flushTimer;
  
  NetworkStatus _currentNetworkStatus = NetworkStatus.offline;
  bool _isBridgeRunning = false;
  bool _isPaused = true;
  bool _isFlushing = false;
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
    this._policy,
  ) {
    _initNetworkMonitoring();
    _initPolicyMonitoring();
  }

  void _initNetworkMonitoring() {
    _edgeClient.bindConnectionStatus((isConnected) {
      _connectionMonitor.updateEdgeConnection(isConnected);
    });

    _connectionMonitor.statusStream.listen((status) async {
      _currentNetworkStatus = status;
      _isPaused = !_canSendNow();
      if (_isPaused) {
        await _bufferManager.persistNow();
      } else {
        _reconfigureFlushLoop();
      }
      _emitRuntimeStatus();
      if (_canSendNow()) {
        await _flushBufferToEdge();
      }
    });
  }

  void _initPolicyMonitoring() {
    _policy.stream.listen((state) async {
      _connectionMonitor.updateUserId(state.adminUserId);
      _isPaused = !_canSendNow();
      if (_isPaused) {
        await _bufferManager.persistNow();
      }
      _reconfigureFlushLoop();
      _emitRuntimeStatus();
    });
  }

  bool _canSendNow() {
    if (_currentNetworkStatus != NetworkStatus.online) return false;
    if (_policy.state.wifiOnly && !_connectionMonitor.isWifiConnection) return false;
    return true;
  }

  void startBridge() {
    if (_isBridgeRunning) return;
    _isBridgeRunning = true;
    _connectionMonitor.updateUserId(_policy.state.adminUserId);
    _sensorService.startStreaming();
    _sensorSub = _sensorService.sensorStream.listen((packet) async {
      final updatedPacket = packet.copyWith(
        networkStatus: _currentNetworkStatus,
        userId: _policy.state.adminUserId,
      );
      
      _bufferManager.addPacket(updatedPacket);
      _isPaused = !_canSendNow();
      if (_isPaused || _policy.state.speed != TransmissionSpeed.realTime) {
        await _bufferManager.persistNow();
      }
      _emitRuntimeStatus();

      if (_policy.state.speed == TransmissionSpeed.realTime && _canSendNow()) {
        await _flushBufferToEdge();
      }
    });
    _reconfigureFlushLoop();
    _emitRuntimeStatus();
  }

  Stream<Map<String, dynamic>> get runtimeStatusStream =>
      _runtimeStatusController.stream;
  NetworkStatus get currentNetworkStatus => _currentNetworkStatus;
  int get retryCount => _retryCount;
  int get totalSentPackets => _totalSentPackets;
  int get lastBatchSentCount => _lastBatchSentCount;
  bool get isBridgeRunning => _isBridgeRunning;

  void _reconfigureFlushLoop() {
    _flushTimer?.cancel();
    if (!_isBridgeRunning) return;
    final interval = _policy.state.flushInterval;
    if (interval == Duration.zero) return;

    _flushTimer = Timer.periodic(interval, (_) async {
      if (!_canSendNow()) {
        _isPaused = true;
        await _bufferManager.persistNow();
        _emitRuntimeStatus();
        return;
      }
      _isPaused = false;
      await _flushBufferToEdge();
    });
  }

  void _emitRuntimeStatus() {
    _runtimeStatusController.add({
      'networkStatus': _currentNetworkStatus.name,
      'retryCount': _retryCount,
      'totalSentPackets': _totalSentPackets,
      'lastBatchSentCount': _lastBatchSentCount,
      'isBridgeRunning': _isBridgeRunning,
      'isPaused': _isPaused,
      'bufferSize': _bufferManager.currentSize,
      'isWearConnected': _connectionMonitor.isWearConnected,
      'isEdgeConnected': _connectionMonitor.isEdgeConnected,
      'currentUserId': _connectionMonitor.currentUserId,
      'connectedWatchName': _connectionMonitor.connectedWatchName,
      'connectedWatchModel': _connectionMonitor.connectedWatchModel,
      'speed': _policy.state.speed.name,
      'wifiOnly': _policy.state.wifiOnly,
      'isWifiConnection': _connectionMonitor.isWifiConnection,
    });
  }

  Future<void> _flushBufferToEdge() async {
    if (!_canSendNow() || _isFlushing) return;
    _isFlushing = true;
    
    final packets = await _bufferManager.flushAndGetPackets();
    if (packets.isEmpty) {
      _isFlushing = false;
      return;
    }

    try {
      // 전송 시도
      await _edgeClient.sendBatch(
        packets,
        headers: {
          'x-user-id': _connectionMonitor.currentUserId,
          'x-device-model': packets.first.deviceModel,
          'x-device-os': packets.first.deviceOs,
          'x-watch-name': _connectionMonitor.connectedWatchName,
        },
      );
      
      // 성공 시: 재시도 횟수 초기화 및 성공 로그
      _retryCount = 0;
      _lastBatchSentCount = packets.length;
      _totalSentPackets += packets.length;
      _isPaused = false;
      _emitRuntimeStatus();
      print("🎯 [Sync]: ${packets.length}개 패킷 전송 완료 및 확인됨.");
      
    } catch (e) {
      _retryCount++;
      _isPaused = true;
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
      
      if (_canSendNow()) {
        await _flushBufferToEdge();
      }
    } finally {
      _isFlushing = false;
    }
  }

  void stopBridge() {
    _isBridgeRunning = false;
    _sensorSub?.cancel();
    _flushTimer?.cancel();
    _sensorSub = null;
    _sensorService.stopStreaming();
    _isPaused = true;
    _emitRuntimeStatus();
  }
  
}