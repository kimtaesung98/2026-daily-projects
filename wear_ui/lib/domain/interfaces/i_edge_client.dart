import '../entities/sensor_packet.dart';

abstract class IEdgeClient {
  /// Edge 디바이스로 센서 패킷 묶음을 전송합니다.
  /// 전송 실패 시 Exception을 던져 SyncService가 버퍼를 복구할 수 있게 해야 합니다.
  Future<void> sendBatch(
    List<SensorPacket> packets, {
    required Map<String, String> headers,
  });

  /// MQTT 연결 상태 변화를 감지합니다.
  void bindConnectionStatus(void Function(bool isConnected) onChanged);
}