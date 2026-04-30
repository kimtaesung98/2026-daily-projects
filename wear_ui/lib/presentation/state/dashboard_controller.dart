import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'dart:async';
import '../../domain/interfaces/i_sensor_service.dart';
import '../../domain/interfaces/i_connection_monitor.dart';
import '../../domain/interfaces/i_buffer_manager.dart';
import '../../network/sync_service.dart';
import '../../domain/entities/sensor_packet.dart';
import '../../core/types/network_status.dart';
import '../../core/services/background_service_manager.dart';

class DashboardController extends ChangeNotifier {
  final ISensorService sensorService;
  final IBufferManager bufferManager;
  final IConnectionMonitor connectionMonitor;
  final SyncService syncService;

  SensorPacket? latestPacket;
  NetworkStatus currentNetworkStatus = NetworkStatus.offline;
  int currentBufferSize = 0;
  int totalSentPackets = 0;
  int retryCount = 0;
  bool isStreaming = false;
  StreamSubscription? _backgroundStatusSub;

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

    _bindBackgroundStatusChannel();
  }

  void _bindBackgroundStatusChannel() {
    final service = FlutterBackgroundService();
    _backgroundStatusSub = service
        .on(BackgroundServiceManager.statusEvent)
        .listen((event) {
      if (event == null) return;

      final statusName = event['networkStatus']?.toString();
      if (statusName != null) {
        currentNetworkStatus = NetworkStatus.values.firstWhere(
          (e) => e.name == statusName,
          orElse: () => currentNetworkStatus,
        );
      }
      currentBufferSize =
          int.tryParse(event['bufferSize']?.toString() ?? '') ?? currentBufferSize;
      totalSentPackets = int.tryParse(event['totalSentPackets']?.toString() ?? '') ??
          totalSentPackets;
      retryCount = int.tryParse(event['retryCount']?.toString() ?? '') ?? retryCount;
      isStreaming = event['isBridgeRunning'] == true;
      notifyListeners();
    });
    service.invoke(BackgroundServiceManager.pingEvent);
  }

  void toggleStreaming() {
    final service = FlutterBackgroundService();
    if (isStreaming) {
      service.invoke(BackgroundServiceManager.stopEvent);
      syncService.stopBridge();
    } else {
      service.invoke(BackgroundServiceManager.startEvent);
      syncService.startBridge();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _backgroundStatusSub?.cancel();
    super.dispose();
  }
}