import 'package:flutter/material.dart';

// Provider에서 데이터를 읽어올 필요조차 없습니다. (index도 안 받음)
class InfoDetailScreen extends StatelessWidget {
  const InfoDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Info')),
      body: const Center(
        child: Text('v1.0.0\nAll systems running normally.', textAlign: TextAlign.center),
      ),
    );
  }
}