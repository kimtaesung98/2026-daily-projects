// lib/domain/node/machine/machine_model.dart
import 'package:flutter/material.dart';
import 'base_node.dart';
import '../screen/machine_detail_screen.dart'; // 모델이 자신의 스크린을 알고 있음

class MachineNode extends BaseNode {
  @override
  final String title;
  final double operatingRate;

  MachineNode({required this.title, this.operatingRate = 95.0});

  @override
  Widget buildDetailScreen(BuildContext context) {
    // 본인이 직접 본인의 화면을 생성해서 전달
    return MachineDetailScreen(node: this);
  }
}