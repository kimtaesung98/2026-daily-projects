import 'package:flutter/foundation.dart';
import '../../domain/interfaces/i_sensor_service.dart';
import '../../domain/interfaces/i_connection_monitor.dart';
import '../../buffer/buffer_manager.dart';
import '../../network/sync_service.dart';
import '../../domain/entities/sensor_packet.dart';
import '../../core/types/network_status.dart';

class DashboardController extends ChangeNotifier {
  final ISensorService sensorService;
  final IBufferManager bufferManager;
  final IConnectionMonitor connectionMonitor;
  final SyncService syncService;

  SensorPacket? latestPacket;
  NetworkStatus currentNetworkStatus = NetworkStatus.offline;
  int currentBufferSize = 0;
  bool isStreaming = false;

  DashboardController({
    required this.sensorService,
    required this.bufferManager,
    required this.connectionMonitor,
    required this.syncService,
  }) {
    sensorService.sensorStream.listen((packet) {
      latestPacket = packet;
      notifyListeners();
    });

    bufferManager.bufferSizeStream.listen((size) {
      currentBufferSize = size;
      notifyListeners();
    });

    connectionMonitor.statusStream.listen((status) {
      currentNetworkStatus = status;
      notifyListeners();
    });
  }

  void toggleStreaming() {
    if (isStreaming) {
      syncService.stopBridge();
    } else {
      syncService.startBridge();
    }
    isStreaming = !isStreaming;
    notifyListeners();
  }
}