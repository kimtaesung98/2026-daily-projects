// lib/screen/grid_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/grid_provider.dart';

class GridScreen extends StatelessWidget {
  const GridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GridProvider>(context);

    return Scaffold(
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.0, // 허쉬 바 비율
        ),
        itemCount: provider.nodes.length,
        itemBuilder: (context, index) {
          final node = provider.nodes[index];
          
          return GestureDetector(
            onTap: () {
              // GridScreen은 어떤 화면인지 몰라도 됩니다.
              // 노드가 주는 화면을 그냥 띄울 뿐입니다.
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => node.buildDetailScreen(context)),
              );
            },
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