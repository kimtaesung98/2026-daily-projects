import 'package:flutter/material.dart';

abstract class BaseNode {
  String get title;

  @override
  Widget buildDetailScreen(BuildContext context) {
    // GridScreen은 이 메서드를 호출만 하면 됩니다.
    return NeedDetailScreen(node: this);
  }
}