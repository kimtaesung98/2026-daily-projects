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
import '../../core/policy/transmission_policy.dart';

class DashboardController extends ChangeNotifier {
  final ISensorService sensorService;
  final IBufferManager bufferManager;
  final IConnectionMonitor connectionMonitor;
  final SyncService syncService;
  final TransmissionPolicy transmissionPolicy;

  SensorPacket? latestPacket;
  NetworkStatus currentNetworkStatus = NetworkStatus.offline;
  int currentBufferSize = 0;
  int totalSentPackets = 0;
  int retryCount = 0;
  bool isStreaming = false;
  bool isPaused = true;
  bool isWearConnected = false;
  bool isEdgeConnected = false;
  String currentUserId = 'unknown';
  String connectedWatchName = 'Disconnected';
  String connectedWatchModel = 'Unknown';
  final List<String> recentPacketLogs = [];
  TransmissionSpeed speed = TransmissionSpeed.realTime;
  bool wifiOnly = false;
  bool isWifiConnection = false;
  StreamSubscription? _backgroundStatusSub;
  StreamSubscription? _policySub;

  DashboardController({
    required this.sensorService,
    required this.bufferManager,
    required this.connectionMonitor,
    required this.syncService,
    required this.transmissionPolicy,
  }) {
    speed = transmissionPolicy.state.speed;
    wifiOnly = transmissionPolicy.state.wifiOnly;

    sensorService.sensorStream.listen((packet) {
      latestPacket = packet;
      recentPacketLogs.insert(0, _toCompactLog(packet));
      if (recentPacketLogs.length > 20) {
        recentPacketLogs.removeRange(20, recentPacketLogs.length);
      }
      notifyListeners();
    });

    bufferManager.bufferSizeStream.listen((size) {
      currentBufferSize = size;
      notifyListeners();
    });

    connectionMonitor.statusStream.listen((status) {
      currentNetworkStatus = status;
      isWearConnected = connectionMonitor.isWearConnected;
      isEdgeConnected = connectionMonitor.isEdgeConnected;
      currentUserId = connectionMonitor.currentUserId;
      connectedWatchName = connectionMonitor.connectedWatchName;
      connectedWatchModel = connectionMonitor.connectedWatchModel;
      notifyListeners();
    });

    _policySub = transmissionPolicy.stream.listen((state) {
      speed = state.speed;
      wifiOnly = state.wifiOnly;
      currentUserId = state.adminUserId;
      notifyListeners();
    });

    _bindBackgroundStatusChannel();
  }

  String _toCompactLog(SensorPacket packet) {
    final time =
        '${packet.timestamp.hour.toString().padLeft(2, '0')}:${packet.timestamp.minute.toString().padLeft(2, '0')}:${packet.timestamp.second.toString().padLeft(2, '0')}';
    return '[$time] sensor(${packet.gyroX.toStringAsFixed(2)},${packet.gyroY.toStringAsFixed(2)},${packet.gyroZ.toStringAsFixed(2)}) | buffer:$currentBufferSize | ${currentNetworkStatus.name}';
  }

  void _bindBackgroundStatusChannel() {
    try {
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
        isPaused = event['isPaused'] == true;
        isWearConnected = event['isWearConnected'] == true;
        isEdgeConnected = event['isEdgeConnected'] == true;
        currentUserId = event['currentUserId']?.toString() ?? currentUserId;
        connectedWatchName =
            event['connectedWatchName']?.toString() ?? connectedWatchName;
        connectedWatchModel =
            event['connectedWatchModel']?.toString() ?? connectedWatchModel;
        isWifiConnection = event['isWifiConnection'] == true;
        final speedName = event['speed']?.toString();
        if (speedName != null) {
          speed = TransmissionSpeed.values.firstWhere(
            (e) => e.name == speedName,
            orElse: () => speed,
          );
        }
        wifiOnly = event['wifiOnly'] == true;
        notifyListeners();
      });
      service.invoke(BackgroundServiceManager.pingEvent);
    } catch (_) {
      // Widget tests may not register background service platform channels.
    }
  }

  Future<void> updatePolicy({
    TransmissionSpeed? speed,
    bool? wifiOnly,
    String? adminUserId,
    String? adminPassword,
  }) async {
    await transmissionPolicy.update(
      speed: speed,
      wifiOnly: wifiOnly,
      adminUserId: adminUserId,
      adminPassword: adminPassword,
    );
    final service = FlutterBackgroundService();
    service.invoke(
      BackgroundServiceManager.updatePolicyEvent,
      transmissionPolicy.state.toMap(),
    );
  }

  @Deprecated('Autonomous flow: manual start/stop disabled.')
  void toggleStreaming() {}

  @override
  void dispose() {
    _backgroundStatusSub?.cancel();
    _policySub?.cancel();
    super.dispose();
  }
}