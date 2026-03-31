import 'package:flutter/material.dart';
import '../model/base_node.dart';
import '../screen/models.dart';
import '../screen/machine_detail_screen.dart';

class GridProvider with ChangeNotifier {
  // 여기에 노드를 추가하면 그리드가 자동으로 늘어납니다.
  final List<BaseNode> _nodes = [
    
    Node01(),
    Node02(),
    // 추후 새로운 모델 파일 생성 후 이곳에 인스턴스 추가
    MachineNode(title: "LINE-B PACKAGING", operatingRate: 75.0),
    ImageNode(title: "Sample Image", imageUrl: "https://example.com/image.jpg"),
  ];

  List<BaseNode> get nodes => _nodes;
}