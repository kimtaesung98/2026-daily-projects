import '../domain/entities/sensor_packet.dart';

/// 나중에 실제 DB 연동 시 이 인터페이스를 구현(implements)하면 됩니다.
abstract class IStorageAdapter {
  Future<void> initDatabase();
  Future<void> savePackets(List<SensorPacket> packets);
  Future<List<SensorPacket>> loadUnsyncedPackets();
  Future<void> deleteSyncedPackets(List<int> sequenceNumbers);
}