import 'dart:collection';
import '../domain/entities/sensor_packet.dart';
import 'dart:async';
import '../domain/interfaces/i_buffer_manager.dart';
// abstract class IBufferManager {
//   void addPacket(SensorPacket packet);
//   List<SensorPacket> flushAndGetPackets();
//   int get currentSize;
//   Stream<int> get bufferSizeStream;
// }

class BufferManager implements IBufferManager {
  final Queue<SensorPacket> _memoryQueue = Queue<SensorPacket>();
  final int _maxMemoryLimit = 5000; // Prevent memory overflow
  
  // Expose buffer size for UI
  final StreamController<int> _sizeController = StreamController<int>.broadcast();

  @override
  Stream<int> get bufferSizeStream => _sizeController.stream;

  @override
  int get currentSize => _memoryQueue.length;

  @override
  void addPacket(SensorPacket packet) {
    if (_memoryQueue.length >= _maxMemoryLimit) {
      /* ==============================================================================*/
      // Drop oldest packets if offline for too long (or move to local storage adapter)
      _memoryQueue.removeFirst(); 
      // Make buffer to stage packets for edge transmission, not a long-term storage solution
      /* ==============================================================================*/
    }
    _memoryQueue.addLast(packet);
    _sizeController.add(_memoryQueue.length);
  }

  @override
   Future<List<SensorPacket>>  flushAndGetPackets() { 
    final packetsToSync = _memoryQueue.toList();
    _memoryQueue.clear();
    _sizeController.add(0);
    return Future.value(packetsToSync);
  }

  @override
  Future<void> persistNow() async {}
}