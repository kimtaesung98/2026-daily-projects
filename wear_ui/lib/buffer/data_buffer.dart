import 'dart:collection';
import '../domain/entities/sensor_packet.dart';
import '../core/constants/app_constants.dart';

/// 순수하게 데이터를 담아두고 빼는 컬렉션 래퍼입니다.
class DataBuffer {
  final Queue<SensorPacket> _queue = Queue<SensorPacket>();

  void push(SensorPacket packet) {
    if (_queue.length >= AppConstants.maxMemoryBufferLimit) {
      _queue.removeFirst(); // 오버플로우 방지를 위한 오래된 데이터 폐기
    }
    _queue.addLast(packet);
  }

  List<SensorPacket> popAll() {
    final elements = _queue.toList();
    _queue.clear();
    return elements;
  }

  int get length => _queue.length;
  bool get isEmpty => _queue.isEmpty;
}