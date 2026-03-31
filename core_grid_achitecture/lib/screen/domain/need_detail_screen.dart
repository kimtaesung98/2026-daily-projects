import 'package:flutter/material.dart';
import '../../model/need_node.dart';

class NeedDetailScreen extends StatelessWidget {
  final NeedNode node;

  const NeedDetailScreen({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(node.title),
        backgroundColor: Colors.amber[100], // Need 노드만의 테마색
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "상세 정보",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(node.description),
            const Divider(height: 30),
            Row(
              children: [
                const Icon(Icons.priority_high, color: Colors.red),
                Text("긴급도: ${node.urgency} / 5"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}