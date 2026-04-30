import 'package:flutter/material.dart';

import '../../dependency_injection/locator.dart';
import '../state/dashboard_controller.dart';

class AdminMonitorScreen extends StatefulWidget {
  const AdminMonitorScreen({super.key});

  @override
  State<AdminMonitorScreen> createState() => _AdminMonitorScreenState();
}

class _AdminMonitorScreenState extends State<AdminMonitorScreen> {
  final DashboardController controller = locator<DashboardController>();

  @override
  void initState() {
    super.initState();
    controller.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    controller.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0D1117);
    const panel = Color(0xFF161B22);
    const text = Color(0xFFC9D1D9);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: panel,
        foregroundColor: text,
        title: const Text(
          'Developer Admin Monitor',
          style: TextStyle(fontFamily: 'monospace'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _infoPanel(panel, text),
            const SizedBox(height: 12),
            Expanded(child: _logPanel(panel, text)),
          ],
        ),
      ),
    );
  }

  Widget _infoPanel(Color panel, Color text) {
    return Card(
      color: panel,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('userId: ${controller.currentUserId}',
                style: TextStyle(color: text, fontFamily: 'monospace')),
            const SizedBox(height: 6),
            Text('watch: ${controller.connectedWatchName}',
                style: TextStyle(color: text, fontFamily: 'monospace')),
            const SizedBox(height: 10),
            Row(
              children: [
                _signalLight('Wear-Phone', controller.isWearConnected),
                const SizedBox(width: 10),
                _signalLight('Phone-Edge', controller.isEdgeConnected),
                const SizedBox(width: 10),
                _signalLight('Sync', !controller.isPaused && controller.isStreaming),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _signalLight(String label, bool active) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? Colors.greenAccent : Colors.redAccent,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFC9D1D9),
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _logPanel(Color panel, Color text) {
    final logs = controller.recentPacketLogs;
    return Card(
      color: panel,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: logs.isEmpty
            ? Center(
                child: Text(
                  'No packets yet',
                  style: TextStyle(color: text, fontFamily: 'monospace'),
                ),
              )
            : ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                    child: Text(
                      logs[index],
                      style: TextStyle(color: text, fontFamily: 'monospace'),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
