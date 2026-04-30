import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../dependency_injection/locator.dart';
import '../policy/transmission_policy.dart';
import '../../domain/interfaces/i_buffer_manager.dart';
import '../../domain/interfaces/i_connection_monitor.dart';
import '../../network/sync_service.dart';

class BackgroundServiceManager {
  static const String _notificationChannelId = 'sensor_bridge_channel';
  static const String _notificationChannelName = 'Sensor Bridge Service';
  static const int _foregroundNotificationId = 9001;
  static const String statusEvent = 'bridgeStatus';
  static const String startEvent = 'startBridge';
  static const String stopEvent = 'stopBridge';
  static const String pingEvent = 'requestStatus';
  static const String updatePolicyEvent = 'updatePolicy';

  static final FlutterBackgroundService _service = FlutterBackgroundService();
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeService() async {
    WidgetsFlutterBinding.ensureInitialized();
    await _createNotificationChannel();

    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        autoStartOnBoot: true,
        isForegroundMode: true,
        notificationChannelId: _notificationChannelId,
        initialNotificationTitle: 'Sensor Bridge',
        initialNotificationContent: '백그라운드 브릿지 초기화 중',
        foregroundServiceNotificationId: _foregroundNotificationId,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
      ),
    );

    await _service.startService();
  }

  static Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      _notificationChannelId,
      _notificationChannelName,
      description: 'Maintains sensor collection and edge sync state.',
      importance: Importance.low,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
  }

  @pragma('vm:entry-point')
  static Future<void> onStart(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    if (!locator.isRegistered<IBufferManager>()) {
      setupLocator();
    }

    final syncService = locator<SyncService>();
    final bufferManager = locator<IBufferManager>();
    final monitor = locator<IConnectionMonitor>();
    final policy = locator<TransmissionPolicy>();
    await policy.load();
    syncService.startBridge();

    void publishStatus() {
      final payload = <String, dynamic>{
        'networkStatus': monitor.currentStatus.name,
        'bufferSize': bufferManager.currentSize,
        'totalSentPackets': syncService.totalSentPackets,
        'lastBatchSentCount': syncService.lastBatchSentCount,
        'retryCount': syncService.retryCount,
        'isBridgeRunning': syncService.isBridgeRunning,
        'speed': policy.state.speed.name,
        'wifiOnly': policy.state.wifiOnly,
        'isWifiConnection': monitor.isWifiConnection,
      };

      service.invoke(statusEvent, payload);

      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: 'Sensor Bridge (${payload['networkStatus']})',
          content:
              'TX:${payload['totalSentPackets']}  Buffer:${payload['bufferSize']}  Retry:${payload['retryCount']}',
        );
      }
    }

    syncService.runtimeStatusStream.listen((_) => publishStatus());
    Timer.periodic(const Duration(seconds: 5), (_) => publishStatus());
    publishStatus();

    service.on(startEvent).listen((_) {
      syncService.startBridge();
      publishStatus();
    });

    service.on(stopEvent).listen((_) {
      syncService.stopBridge();
      publishStatus();
    });

    service.on(pingEvent).listen((_) => publishStatus());
    service.on(updatePolicyEvent).listen((event) async {
      if (event == null) return;
      await policy.applyRemote(event);
      publishStatus();
    });
  }
}
