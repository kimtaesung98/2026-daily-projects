import 'package:flutter/material.dart';

abstract class BaseNode {
  String get title;
  
  // 핵심: 모든 노드는 이 메서드를 구현해서 자신의 상세 화면을 반환해야 함
  Widget buildDetailScreen(BuildContext context);
}