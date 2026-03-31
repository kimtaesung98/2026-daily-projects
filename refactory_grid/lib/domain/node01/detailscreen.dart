import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/gridprovider.dart';

class Node01DetailScreen extends StatelessWidget {
  final int nodeIndex; // 인덱스를 주입받음
  
  const Node01DetailScreen({super.key, required this.nodeIndex});

  @override
  Widget build(BuildContext context) {
    // 하드코딩 없이 주입받은 인덱스로 데이터 접근
    final node = context.watch<GridProvider>().nodes[nodeIndex];
    
    return Scaffold(
      appBar: AppBar(title: Text(node.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('STATUS: ${node.status}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('VALUE: ${node.value}', style: const TextStyle(fontSize: 20, color: Colors.grey)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.read<GridProvider>().updateNodeValue(nodeIndex, node.value + 1);
              },
              child: const Text('Increment Value'),
            )
          ],
        ),
      ),
    );
  }
}