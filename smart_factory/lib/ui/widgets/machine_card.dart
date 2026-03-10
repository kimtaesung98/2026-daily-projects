import 'package:flutter/material.dart';
import '../../data/models/machine_model.dart';

class MachineCard extends StatelessWidget {
  final MachineModel machine;
  const MachineCard({super.key, required this.machine});

  @override
  Widget build(BuildContext context) {
    final bool isWarning = machine.temperature > 85; // 85도 이상이면 경고

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isWarning ? Colors.redAccent : Colors.white10),
        boxShadow: [
          if (isWarning) BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 10)
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(machine.id, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                _statusBadge(isWarning),
              ],
            ),
            const SizedBox(height: 8),
            Text(machine.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            _buildDataRow("Temperature", "${machine.temperature.toStringAsFixed(1)}°C", isWarning ? Colors.red : Colors.cyanAccent),
            _buildDataRow("Pressure", "${machine.pressure.toStringAsFixed(1)} psi", Colors.greenAccent),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(bool isWarning) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isWarning ? Colors.red : Colors.green,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(isWarning ? "WARNING" : "NORMAL", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDataRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Consolas')),
      ],
    );
  }
  
}