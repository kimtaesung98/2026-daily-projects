import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'machine_model.dart';

class FactoryProvider extends ChangeNotifier {
  List<MachineModel> _machines = [];
  List<MachineModel> get machines => _machines;
  
  StreamSubscription? _subscription;

  // 모니터링 시작 (데이터 수집 개시)
  void startMonitoring() {
    // 1초마다 무작위 데이터를 생성하여 리스트를 갱신
    _subscription = Stream.periodic(const Duration(seconds: 1)).listen((_) {
      _machines = List.generate(4, (index) {
        final rand = math.Random();
        double temp = 50.0 + rand.nextDouble() * 50; // 50~100도
        
        return MachineModel(
          id: "LINE-0${index + 1}",
          name: "${index + 1}번 생산 라인",
          temperature: temp,
          pressure: 80.0 + rand.nextDouble() * 40,   // 80~120압력
          status: temp > 90 ? "WARNING" : "RUNNING", // 90도 넘으면 경고
          lastUpdate: DateTime.now(),
        );
      });
      
      notifyListeners(); // 중요: UI에게 "데이터 바뀌었으니 다시 그려!"라고 신호 보냄
    });
  }

  @override
  void dispose() {
    _subscription?.cancel(); // 앱 종료 시 데이터 수집 중단
    super.dispose();
  }
}