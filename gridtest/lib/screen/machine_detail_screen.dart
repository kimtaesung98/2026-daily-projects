import 'package:flutter/material.dart';
import '../model/machine_model.dart';

class MachineDetailScreen extends StatelessWidget {
  final MachineNode node;
  const MachineDetailScreen({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: Text("${node.title} Monitoring")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("MACHINE ID: ${node.title}", style: const TextStyle(fontSize: 18, color: Colors.white54)),
            const Divider(color: Colors.white24),
            const SizedBox(height: 20),
            // 가동률 표시 (단순 텍스트 묘사)
            Text("OPERATING RATE: ${node.operatingRate}%", 
                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, 
                 color: node.operatingRate > 90 ? Colors.greenAccent : Colors.orangeAccent)),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}