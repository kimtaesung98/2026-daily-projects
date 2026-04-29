import '../../domain/entities/sensor_packet.dart';

abstract class ISensorService {
  Stream<SensorPacket> get sensorStream;
  void startStreaming();
  void stopStreaming();
  void dispose();
}