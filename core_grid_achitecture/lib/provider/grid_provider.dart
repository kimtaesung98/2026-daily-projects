import 'package:flutter/material.dart';
import '../model/models.dart'; // 이거 한 줄이면 끝납니다.

class GridProvider with ChangeNotifier {
  // 1. 노드 타입 정의 (새로운 노드 추가 시 여기만 업데이트)
  final List<BaseNode> _nodes = [
    CurrentWeatherNode(),
    Node01(),
    NeedNode(title: "업무 보조", description: "설명", urgency: 4),
  ];
  List<BaseNode> get nodes => _nodes;

  // 2. 혹은 외부에서 데이터를 받아와서 mapping (가장 권장)
  void addNode(BaseNode newNode) {
    _nodes.add(newNode);
    notifyListeners();
  }
}