import 'package:flutter/material.dart';
import 'base_node.dart';
import '../screen/domain/need_detail_screen.dart'; // 모델이 스크린을 참조하게 됩니다.

class NeedNode implements BaseNode {
  @override
  final String title;
  final String description;
  final int urgency;

  NeedNode({required this.title, required this.description, this.urgency = 3});

  @override
  Widget buildDetailScreen(BuildContext context) {
    // GridScreen은 이 메서드를 호출만 하면 됩니다.
    return NeedDetailScreen(node: this);
  }
}