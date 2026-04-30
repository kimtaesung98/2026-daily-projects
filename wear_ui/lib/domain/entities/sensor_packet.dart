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
  final String userId;
  final String deviceModel;
  final String deviceOs;
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
    required this.userId,
    required this.deviceModel,
    required this.deviceOs,
    required this.sequenceNumber,
    required this.networkStatus,
  });

  SensorPacket copyWith({
    NetworkStatus? networkStatus,
    String? userId,
    String? deviceModel,
    String? deviceOs,
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
      userId: userId ?? this.userId,
      deviceModel: deviceModel ?? this.deviceModel,
      deviceOs: deviceOs ?? this.deviceOs,
      sequenceNumber: sequenceNumber,
      networkStatus: networkStatus ?? this.networkStatus,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'gyroX': gyroX,
      'gyroY': gyroY,
      'gyroZ': gyroZ,
      'accelX': accelX,
      'accelY': accelY,
      'accelZ': accelZ,
      'deviceId': deviceId,
      'userId': userId,
      'deviceModel': deviceModel,
      'deviceOs': deviceOs,
      'sequenceNumber': sequenceNumber,
      'networkStatus': networkStatus.name,
    };
  }
}