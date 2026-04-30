import 'package:flutter/material.dart';

import '../../core/policy/transmission_policy.dart';
import '../../dependency_injection/locator.dart';
import '../state/dashboard_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DashboardController controller = locator<DashboardController>();
  late TransmissionSpeed _speed;
  late bool _wifiOnly;
  late TextEditingController _userIdController;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _speed = controller.speed;
    _wifiOnly = controller.wifiOnly;
    _userIdController = TextEditingController(text: controller.currentUserId);
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _speedLabel(TransmissionSpeed speed) {
    switch (speed) {
      case TransmissionSpeed.realTime:
        return 'RT (Real-time)';
      case TransmissionSpeed.oneSecond:
        return '1s';
      case TransmissionSpeed.threeSeconds:
        return '3s';
      case TransmissionSpeed.fiveSeconds:
        return '5s';
    }
  }

  Future<void> _save() async {
    await controller.updatePolicy(
      speed: _speed,
      wifiOnly: _wifiOnly,
      adminUserId: _userIdController.text.trim().isEmpty
          ? controller.currentUserId
          : _userIdController.text.trim(),
      adminPassword:
          _passwordController.text.isEmpty ? null : _passwordController.text,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Identity', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Wear Device: ${controller.connectedWatchName}'),
          Text('Wear Model: ${controller.connectedWatchModel}'),
          const SizedBox(height: 8),
          TextField(
            controller: _userIdController,
            decoration: const InputDecoration(
              labelText: 'Admin User ID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Control', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<TransmissionSpeed>(
            initialValue: _speed,
            decoration: const InputDecoration(
              labelText: 'Transmission Speed',
              border: OutlineInputBorder(),
            ),
            items: TransmissionSpeed.values
                .map(
                  (speed) => DropdownMenuItem(
                    value: speed,
                    child: Text(_speedLabel(speed)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _speed = value);
              }
            },
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Wi-Fi only mode'),
            value: _wifiOnly,
            onChanged: (value) => setState(() => _wifiOnly = value),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Change admin password',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
