import 'dart:async';
import '../domain/entities/sensor_packet.dart';
import '../domain/interfaces/i_buffer_manager.dart';
import 'storage_adapter.dart';

class PersistentBufferManager implements IBufferManager {
  final IStorageAdapter _storage;
  final List<SensorPacket> _memoryCache = [];
  final int _flushThreshold = 100; // 100개가 쌓이면 DB로 덤프
  final Future<void> _initFuture;

  final StreamController<int> _sizeController =
      StreamController<int>.broadcast();

  PersistentBufferManager(this._storage) : _initFuture = _storage.initDatabase();

  @override
  Stream<int> get bufferSizeStream => _sizeController.stream;

  @override
  int get currentSize => _memoryCache.length; // 실제로는 DB 개수까지 합산 필요

  @override
  void addPacket(SensorPacket packet) {
    _memoryCache.add(packet);
    _sizeController.add(_memoryCache.length);

    if (_memoryCache.length >= _flushThreshold) {
      _persistMemoryToDisk();
    }
  }

  Future<void> _persistMemoryToDisk() async {
    await _initFuture;
    final toSave = List<SensorPacket>.from(_memoryCache);
    _memoryCache.clear();
    if (toSave.isEmpty) return;
    await _storage.savePackets(toSave);
    print("💾 [Persistent Buffer]: ${toSave.length} packets moved to SQLite.");
  }

  @override
  Future<List<SensorPacket>> flushAndGetPackets() async {
    await _initFuture;
    await _persistMemoryToDisk();

    final packets = await _storage.loadUnsyncedPackets();
    if (packets.isNotEmpty) {
      final sequenceNumbers = packets.map((p) => p.sequenceNumber).toList();
      await _storage.deleteSyncedPackets(sequenceNumbers);
    }

    _sizeController.add(0);
    return packets;
  }
}