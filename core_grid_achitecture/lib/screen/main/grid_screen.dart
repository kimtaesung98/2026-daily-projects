import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/grid_provider.dart';
import '../../model/models.dart';
class GridScreen extends StatelessWidget {
  const GridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GridProvider>(context);

    return Scaffold(
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: provider.nodes.length,
        itemBuilder: (context, index) {
          final node = provider.nodes[index];
          
          return GestureDetector(
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(
                // 노드가 시키는 대로 화면을 띄웁니다. (다형성 핵심)
                builder: (context) => node.buildDetailScreen(context),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(border: Border.all(width: 0.5)),
              child: Center(child: Text(node.title)),
            ),
          );
        },
      ),
    );
  }
}