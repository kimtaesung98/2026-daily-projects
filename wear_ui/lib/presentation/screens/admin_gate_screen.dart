import 'package:flutter/material.dart';

import '../../dependency_injection/locator.dart';
import '../state/dashboard_controller.dart';
import 'packet_monitor_screen.dart';
import 'settings_screen.dart';

class AdminGateScreen extends StatefulWidget {
  const AdminGateScreen({super.key});

  @override
  State<AdminGateScreen> createState() => _AdminGateScreenState();
}

class _AdminGateScreenState extends State<AdminGateScreen> {
  final DashboardController controller = locator<DashboardController>();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    controller.removeListener(_refresh);
    _passwordController.dispose();
    super.dispose();
  }

  void _openAdmin() {
    final password = _passwordController.text.trim();
    if (password != controller.transmissionPolicy.state.adminPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid password')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PacketMonitorScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Public View'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('User: ${controller.currentUserId}'),
                    Text('Wear: ${controller.connectedWatchName}'),
                    Text('Network: ${controller.currentNetworkStatus.name}'),
                    Text('Buffer: ${controller.currentBufferSize}'),
                    Text('TX: ${controller.totalSentPackets}'),
                    Text('Mode: ${controller.speed.name}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Developer Gatekeeper'),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Admin Password',
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _openAdmin,
              child: const Text('Open Packet Hijacking View'),
            ),
          ],
        ),
      ),
    );
  }
}
