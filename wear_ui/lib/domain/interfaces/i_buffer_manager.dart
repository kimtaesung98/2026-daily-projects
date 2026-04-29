import 'dart:async';
import '../entities/sensor_packet.dart';

/// 센서 데이터 버퍼링을 위한 추상화 인터페이스입니다.
/// 의존성 역전(DIP)을 통해 시스템 결합도를 낮추는 핵심 역할을 합니다.
abstract class IBufferManager {
  /// 새로운 센서 데이터를 버퍼에 추가합니다.
  /// (구현체에서 오버플로우 방지 로직을 처리해야 합니다)
  void addPacket(SensorPacket packet);

  /// 버퍼에 쌓인 모든 데이터를 반환하고, 내부 버퍼를 비웁니다 (Flush).
  /// Edge 디바이스로 전송하기 위해 데이터를 꺼낼 때 사용됩니다.
  List<SensorPacket> flushAndGetPackets();

  /// 현재 버퍼에 보관된 데이터의 개수를 즉시 조회합니다.
  int get currentSize;

  /// UI(Dashboard) 또는 모니터링 시스템에서 실시간으로 
  /// 버퍼의 상태(크기)를 관찰할 수 있도록 스트림을 제공합니다.
  Stream<int> get bufferSizeStream;
}