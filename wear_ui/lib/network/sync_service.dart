import 'dart:async';
import '../domain/interfaces/i_sensor_service.dart';
import '../domain/interfaces/i_connection_monitor.dart';
import '../domain/interfaces/i_edge_client.dart';
import '../buffer/buffer_manager.dart';
import '../core/types/network_status.dart';

class SyncService {
  final ISensorService _sensorService;
  final IBufferManager _bufferManager;
  final IConnectionMonitor _connectionMonitor;
  final IEdgeClient _edgeClient;

  StreamSubscription? _sensorSub;
  StreamSubscription? _networkSub;
  
  NetworkStatus _currentNetworkStatus = NetworkStatus.offline;

  SyncService(
    this._sensorService,
    this._bufferManager,
    this._connectionMonitor,
    this._edgeClient,
  ) {
    _initNetworkMonitoring();
  }

  void _initNetworkMonitoring() {
    _networkSub = _connectionMonitor.statusStream.listen((status) {
      _currentNetworkStatus = status;
      if (status == NetworkStatus.online) {
        _flushBufferToEdge();
      }
    });
  }

  void startBridge() {
    _sensorService.startStreaming();
    _sensorSub = _sensorService.sensorStream.listen((packet) {
      // Tag packet with current known network state
      final updatedPacket = packet.copyWith(networkStatus: _currentNetworkStatus);
      
      _bufferManager.addPacket(updatedPacket);

      // If online, immediately flush buffer (which includes the packet just added)
      if (_currentNetworkStatus == NetworkStatus.online) {
         _flushBufferToEdge();
      }
    });
  }

  Future<void> _flushBufferToEdge() async {
    if (_bufferManager.currentSize == 0) return;
    
    final packets = _bufferManager.flushAndGetPackets();
    try {
      await _edgeClient.sendBatch(packets);
    } catch (e) {
      // If transmission fails, requeue packets
      for (var p in packets) {
        _bufferManager.addPacket(p);
      }
    }
  }

  void stopBridge() {
    _sensorSub?.cancel();
    _sensorService.stopStreaming();
  }
}