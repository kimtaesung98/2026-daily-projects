import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/machine_model.dart';

class FactoryProvider extends ChangeNotifier {

  List<MachineModel> _machines = [];
  List<MachineModel> get machines => _machines;

  List<String> _eventLogs = [];
  List<String> get eventLogs => _eventLogs;

  StreamSubscription? _subscription;

  /// 모니터링 시작
  void startMonitoring() {

    /// 초기 머신 생성
    _machines = List.generate(4, (index) {
      return MachineModel(
        id: "LINE-0${index + 1}",
        name: "${index + 1}번 생산 라인",
        temperature: 60,
        pressure: 100,
        status: "RUNNING",
        lastUpdate: DateTime.now(),
        tempHistory: [],
      );
    });

    /// 센서 데이터 스트림 (1초 주기)
    _subscription =
        Stream.periodic(const Duration(seconds: 1)).listen((_) {

      final rand = math.Random();

      _machines = _machines.map((machine) {

        double newTemp = 50 + rand.nextDouble() * 50;
        double newPressure = 80 + rand.nextDouble() * 40;

        final updatedMachine = machine.copyWith(
          newTemp: newTemp,
          newPressure: newPressure,
        );

        /// 🔥 경고 감지
        _checkAlerts(updatedMachine);

        return updatedMachine;

      }).toList();

      notifyListeners();

    });
  }

  /// 경고 상태 감지
  void _checkAlerts(MachineModel machine) {

    if (machine.status == "WARNING") {

      String log =
          "[${DateTime.now().toString().substring(11, 19)}] "
          "경고: ${machine.name} 온도 ${machine.temperature.toStringAsFixed(1)}°C";

      /// 동일 로그 폭주 방지
      if (_eventLogs.isEmpty || !_eventLogs.first.contains(machine.name)) {

        _eventLogs.insert(0, log);

        /// 로그 최대 50개 유지
        if (_eventLogs.length > 50) {
          _eventLogs.removeLast();
        }

        notifyListeners();
      }
    }
  }

  /// CSV 리포트 생성
  Future<void> exportReport() async {

    String csvData =
        "ID,Name,Temperature,Pressure,Status,Timestamp\n";

    for (var m in _machines) {

      csvData +=
          "${m.id},${m.name},${m.temperature.toStringAsFixed(1)},"
          "${m.pressure.toStringAsFixed(1)},${m.status},${m.lastUpdate}\n";
    }

    /// 학습용 출력
    print("------ CSV REPORT ------");
    print(csvData);

    /// 실제 구현 시
    /// file_picker + path_provider 사용 가능
  }

  /// 모니터링 중지
  void stopMonitoring() {
    _subscription?.cancel();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}