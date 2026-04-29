import 'dart:async';
import '../domain/interfaces/i_edge_client.dart';
import '../domain/entities/sensor_packet.dart';

class MockEdgeClient implements IEdgeClient {
  @override
  Future<void> sendBatch(List<SensorPacket> packets) async {
    if (packets.isEmpty) return;

    print("🚀 [Edge Client]: Initiating transfer of ${packets.length} packets...");
    
    // Simulate network transmission delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulate occasional transmission failure (1 in 5 chance) to test buffer recovery
    final bool isTransmissionFailed = DateTime.now().second % 5 == 0;
    
    if (isTransmissionFailed) {
      print("❌ [Edge Client]: Transmission failed! Target unreachable.");
      throw Exception("Edge device timeout");
    }

    print("✅ [Edge Client]: Successfully delivered ${packets.length} packets to Edge Device.");
  }
}