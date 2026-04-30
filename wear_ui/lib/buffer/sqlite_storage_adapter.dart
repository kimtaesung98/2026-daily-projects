import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../domain/entities/sensor_packet.dart';
import '../core/types/network_status.dart';
import 'storage_adapter.dart';

class SqliteStorageAdapter implements IStorageAdapter {
  static const String _tableName = 'sensor_packets';
  Database? _database;

  @override
  Future<void> initDatabase() async {
    if (_database != null) return;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sensor_bridge.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT,
            gyroX REAL, gyroY REAL, gyroZ REAL,
            accelX REAL, accelY REAL, accelZ REAL,
            deviceId TEXT,
            sequenceNumber INTEGER,
            networkStatus INTEGER
          )
        ''');
      },
    );
  }

  @override
  Future<void> savePackets(List<SensorPacket> packets) async {
    final batch = _database!.batch();
    for (var packet in packets) {
      batch.insert(_tableName, {
        'timestamp': packet.timestamp.toIso8601String(),
        'gyroX': packet.gyroX, 'gyroY': packet.gyroY, 'gyroZ': packet.gyroZ,
        'accelX': packet.accelX, 'accelY': packet.accelY, 'accelZ': packet.accelZ,
        'deviceId': packet.deviceId,
        'sequenceNumber': packet.sequenceNumber,
        'networkStatus': packet.networkStatus.index,
      });
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<List<SensorPacket>> loadUnsyncedPackets() async {
    final List<Map<String, dynamic>> maps = await _database!.query(_tableName);

    return List.generate(maps.length, (i) {
      return SensorPacket(
        timestamp: DateTime.parse(maps[i]['timestamp']),
        gyroX: maps[i]['gyroX'], gyroY: maps[i]['gyroY'], gyroZ: maps[i]['gyroZ'],
        accelX: maps[i]['accelX'], accelY: maps[i]['accelY'], accelZ: maps[i]['accelZ'],
        deviceId: maps[i]['deviceId'],
        sequenceNumber: maps[i]['sequenceNumber'],
        networkStatus: NetworkStatus.values[maps[i]['networkStatus']],
      );
    });
  }

  @override
  Future<void> deleteSyncedPackets(List<int> sequenceNumbers) async {
    // 성능을 위해 대량 삭제 쿼리 사용
    if (sequenceNumbers.isEmpty) return;
    final ids = sequenceNumbers.join(',');
    await _database!.delete(_tableName, where: 'sequenceNumber IN ($ids)');
  }
}