import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import '../domain/interfaces/i_sensor_service.dart';
import '../domain/entities/sensor_packet.dart';
import '../core/types/network_status.dart';

class DeviceSensorService implements ISensorService {
  final StreamController<SensorPacket> _controller = StreamController.broadcast();
  StreamSubscription? _gyroSub;
  StreamSubscription? _accelSub;

  double _gx = 0, _gy = 0, _gz = 0;
  double _ax = 0, _ay = 0, _az = 0;
  int _sequenceCounter = 0;
  final String _deviceId = "EDGE_PHONE_01"; // Mock ID

  @override
  Stream<SensorPacket> get sensorStream => _controller.stream;

  @override
  void startStreaming() {
    _gyroSub ??= gyroscopeEventStream().listen((event) {
      _gx = event.x; _gy = event.y; _gz = event.z;
      _emitPacket();
    });

    _accelSub ??= accelerometerEventStream().listen((event) {
      _ax = event.x; _ay = event.y; _az = event.z;
      // We don't emit here to prevent double-firing, or we can emit on a fixed timer.
      // For this bridge, we emit on gyro updates to keep them synced.
    });
  }

  void _emitPacket() {
    _sequenceCounter++;
    final packet = SensorPacket(
      timestamp: DateTime.now().toUtc(),
      gyroX: _gx, gyroY: _gy, gyroZ: _gz,
      accelX: _ax, accelY: _ay, accelZ: _az,
      deviceId: _deviceId,
      sequenceNumber: _sequenceCounter,
      networkStatus: NetworkStatus.offline, // Default, SyncService updates this
    );
    _controller.add(packet);
  }

  @override
  void stopStreaming() {
    _gyroSub?.cancel();
    _gyroSub = null;
    _accelSub?.cancel();
    _accelSub = null;
  }

  @override
  void dispose() {
    stopStreaming();
    _controller.close();
  }
}