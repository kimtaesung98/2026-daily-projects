import 'package:flutter/material.dart';
import '../domain/node01/model.dart';
import '../domain/node02/model.dart';
import '../domain/node03/model.dart';
import '../domain/node04/model.dart';

class GridProvider extends ChangeNotifier {
  // Using 'dynamic' because NO base classes or abstraction layers are allowed.
  List<dynamic> nodes = [
    Node01Model(),
    Node02Model(),
    InfoNodeModel(),    // 변수 0개짜리 모델
    ComplexNodeModel(), // 변수 N개짜리 모델
  ];

  // Minimal logic to update a node's value and notify the UI
  void updateNodeValue(int index, int newValue) {
    nodes[index].value = newValue;
    notifyListeners();
  }
}