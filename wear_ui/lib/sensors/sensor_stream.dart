import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

/// 써드파티 라이브러리(sensors_plus)의 종속성을 격리하는 래퍼(Wrapper) 클래스입니다.
class SensorStreamWrapper {
  StreamSubscription<GyroscopeEvent>? listenToGyroscope(void Function(GyroscopeEvent) onData) {
    try {
      return gyroscopeEventStream().listen(onData);
    } catch (e) {
      print("Gyroscope stream error: $e");
      return null;
    }
  }

  StreamSubscription<AccelerometerEvent>? listenToAccelerometer(void Function(AccelerometerEvent) onData) {
    try {
      return accelerometerEventStream().listen(onData);
    } catch (e) {
      print("Accelerometer stream error: $e");
      return null;
    }
  }
}