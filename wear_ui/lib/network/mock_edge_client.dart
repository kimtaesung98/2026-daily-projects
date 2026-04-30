import 'dart:async';
import '../domain/interfaces/i_edge_client.dart';
import '../domain/entities/sensor_packet.dart';

class MockEdgeClient implements IEdgeClient {
  void Function(bool isConnected)? _listener;

  @override
  void bindConnectionStatus(void Function(bool isConnected) onChanged) {
    _listener = onChanged;
    _listener?.call(true);
  }

  @override
  Future<void> sendBatch(
    List<SensorPacket> packets, {
    required Map<String, String> headers,
  }) async {
    if (packets.isEmpty) return;

    print("🚀 [Edge Client]: Initiating transfer of ${packets.length} packets...");
    
    // Simulate network transmission delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulate occasional transmission failure (1 in 5 chance) to test buffer recovery
    final bool isTransmissionFailed = DateTime.now().second % 5 == 0;
    
    if (isTransmissionFailed) {
      print("❌ [Edge Client]: Transmission failed! Target unreachable.");
      _listener?.call(false);
      throw Exception("Edge device timeout");
    }

    _listener?.call(true);
    print("✅ [Edge Client]: Successfully delivered ${packets.length} packets to Edge Device.");
  }
}