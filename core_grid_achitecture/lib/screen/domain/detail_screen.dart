import 'package:flutter/material.dart';
import '../../model/base_node.dart';

class DetailScreen extends StatelessWidget {
  final BaseNode node;
  const DetailScreen({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(node.title)),
      body: const Center(child: Text("Structural expansion point.")),
    );
  }
}