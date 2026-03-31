import 'package:flutter/material.dart';
import '../BaseNode.dart';
import 'detailscreen.dart';

class Node01Model extends BaseNodeModel {
  // 기본값을 부모 생성자로 넘깁니다.
  Node01Model() : super(
    title: 'Node 01: Auth',
    status: 'Healthy',
    value: 200,
  );

  @override
  Widget buildDetailScreen(int index) {
    // 하드코딩된 0 대신, 동적으로 부여받은 인덱스를 주입합니다.
    return Node01DetailScreen(nodeIndex: index);
  }
}