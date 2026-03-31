import 'package:flutter/material.dart';

abstract class BaseNodeModel {
  String title; // 필수
  String? status; // 선택 (필요 없는 모델은 안 써도 됨)
  int? value; // 선택 (필요 없는 모델은 안 써도 됨)

  BaseNodeModel({
    required this.title,
    this.status,
    this.value,
  });

  Widget buildDetailScreen(int index);
}