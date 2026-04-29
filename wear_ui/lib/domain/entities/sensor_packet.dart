import 'package:flutter/foundation.dart';
import '../../core/types/network_status.dart';

@immutable
class SensorPacket {
  final DateTime timestamp;
  final double gyroX;
  final double gyroY;
  final double gyroZ;
  final double accelX;
  final double accelY;
  final double accelZ;
  final String deviceId;
  final int sequenceNumber;
  final NetworkStatus networkStatus;

  const SensorPacket({
    required this.timestamp,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    required this.accelX,
    required this.accelY,
    required this.accelZ,
    required this.deviceId,
    required this.sequenceNumber,
    required this.networkStatus,
  });

  SensorPacket copyWith({
    NetworkStatus? networkStatus,
  }) {
    return SensorPacket(
      timestamp: timestamp,
      gyroX: gyroX,
      gyroY: gyroY,
      gyroZ: gyroZ,
      accelX: accelX,
      accelY: accelY,
      accelZ: accelZ,
      deviceId: deviceId,
      sequenceNumber: sequenceNumber,
      networkStatus: networkStatus ?? this.networkStatus,
    );
  }
}