import 'package:flutter/material.dart';
import '../state/dashboard_controller.dart';
import '../../dependency_injection/locator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController controller = locator<DashboardController>();

  @override
  void initState() {
    super.initState();
    controller.addListener(_updateUI);
  }

  void _updateUI() => setState(() {});

  @override
  void dispose() {
    controller.removeListener(_updateUI);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = controller.latestPacket;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Edge Sensor Bridge')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 24),
            if (p != null) ...[
              _buildSensorCard('Gyroscope', p.gyroX, p.gyroY, p.gyroZ),
              const SizedBox(height: 16),
              _buildSensorCard('Accelerometer', p.accelX, p.accelY, p.accelZ),
            ] else
              const Expanded(child: Center(child: Text("Waiting for sensor data..."))),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.toggleStreaming,
        label: Text(controller.isStreaming ? 'Stop Streaming' : 'Start Streaming'),
        icon: Icon(controller.isStreaming ? Icons.stop : Icons.play_arrow),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Network: ${controller.currentNetworkStatus.name.toUpperCase()}"),
            Text("Buffer Size: ${controller.currentBufferSize} packets"),
            Text("Sent Packets: ${controller.totalSentPackets}"),
            Text("Retry Count: ${controller.retryCount}"),
            Text("Bridge Status: ${controller.isStreaming ? 'ACTIVE' : 'IDLE'}"),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard(String title, double x, double y, double z) {
    return Card(
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          'X: ${x.toStringAsFixed(3)}\n'
          'Y: ${y.toStringAsFixed(3)}\n'
          'Z: ${z.toStringAsFixed(3)}',
          style: const TextStyle(fontFamily: 'monospace'),
        ),
      ),
    );
  }
}