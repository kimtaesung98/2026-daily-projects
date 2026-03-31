// lib/domain/node/machine/machine_model.dart
import 'package:flutter/material.dart';
import 'package:gridtest/screen/detail_screen.dart';
import 'base_node.dart';
import '../screen/machine_detail_screen.dart'; // 모델이 자신의 스크린을 알고 있음

class Node02 extends BaseNode {
  @override
  String get title => "NODE 02";
  Node02();

  @override
  Widget buildDetailScreen(BuildContext context) {
    // 본인이 직접 본인의 화면을 생성해서 전달
    return DetailScreen(node: this,);
  }
}