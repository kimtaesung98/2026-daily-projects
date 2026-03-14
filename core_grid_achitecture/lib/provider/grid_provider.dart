import 'package:flutter/material.dart';
import '../model/base_node.dart';
import '../model/current_weather_node.dart';
import '../model/01_node.dart';
import '../model/02_node.dart';
class GridProvider with ChangeNotifier {
  // 여기에 노드를 추가하면 그리드가 자동으로 늘어납니다.
  final List<BaseNode> _nodes = [
    CurrentWeatherNode(),
    
    Node01(),
    Node02(),
    // 추후 새로운 모델 파일 생성 후 이곳에 인스턴스 추가

  ];

  List<BaseNode> get nodes => _nodes;
}