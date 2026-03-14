import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/grid_provider.dart';
import 'detail_screen.dart';

class GridScreen extends StatelessWidget {
  const GridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GridProvider>(context);

    return Scaffold(
      body: GridView.builder(
        // 2열 고정, 화면 비율에 맞춰 확장
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: provider.nodes.length,
        itemBuilder: (context, index) {
          final node = provider.nodes[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => DetailScreen(node: node))
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