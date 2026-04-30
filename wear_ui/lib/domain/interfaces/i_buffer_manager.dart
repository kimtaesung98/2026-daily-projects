import 'dart:async';
import '../entities/sensor_packet.dart';

abstract class IBufferManager {
  void addPacket(SensorPacket packet);
  
  // DB에서 읽어와야 하므로 Future 타입으로 변경합니다.
  Future<List<SensorPacket>> flushAndGetPackets(); 

  /// 현재 메모리 캐시를 즉시 영속화합니다.
  Future<void> persistNow();
  
  int get currentSize;
  Stream<int> get bufferSizeStream;
}