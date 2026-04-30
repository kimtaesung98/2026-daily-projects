import 'package:flutter/material.dart';

import '../../dependency_injection/locator.dart';
import '../state/dashboard_controller.dart';

class PacketMonitorScreen extends StatefulWidget {
  const PacketMonitorScreen({super.key});

  @override
  State<PacketMonitorScreen> createState() => _PacketMonitorScreenState();
}

class _PacketMonitorScreenState extends State<PacketMonitorScreen> {
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
    const panel = Color(0xFF161B22);
    const text = Color(0xFFC9D1D9);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Packet Hijacking Monitor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Card(
          color: panel,
          child: controller.recentPacketLogs.isEmpty
              ? const Center(
                  child: Text(
                    'No packets yet',
                    style: TextStyle(color: text, fontFamily: 'monospace'),
                  ),
                )
              : ListView.builder(
                  itemCount: controller.recentPacketLogs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Text(
                        controller.recentPacketLogs[index],
                        style: const TextStyle(
                          color: text,
                          fontFamily: 'monospace',
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
