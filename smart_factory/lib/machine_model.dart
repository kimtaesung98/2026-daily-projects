import 'dart:math';

class MachineModel {
  final String id;
  final String name;
  final double temperature; // 온도
  final double pressure;    // 압력
  final String status;      // 가동 상태
  final DateTime lastUpdate;
  final List<double> tempHistory; // 최근 온도 기록 (최대 20개)

  MachineModel({
    required this.id,
    required this.name,
    required this.temperature,
    required this.pressure,
    required this.status,
    required this.lastUpdate,
    required this.tempHistory,
  });

  // 기계의 효율을 계산하는 간단한 공식
  // $Efficiency = \frac{Temperature \times 0.6 + Pressure \times 0.4}{150} \times 100$
  double get efficiency => ((temperature * 0.6 + pressure * 0.4) / 150 * 100).clamp(0, 100);

  // 복사본 생성 메서드 (데이터 업데이트 시 유용)
  MachineModel copyWith({double? newTemp, double? newPressure}) {
    List<double> updatedHistory = List.from(tempHistory);
    if (newTemp != null) {
      updatedHistory.add(newTemp);
      if (updatedHistory.length > 20) updatedHistory.removeAt(0); // 20개 유지
    }
    return MachineModel(
      id: id,
      name: name,
      temperature: newTemp ?? temperature,
      pressure: newPressure ?? pressure,
      status: (newTemp ?? temperature) > 90 ? "WARNING" : "RUNNING",
      lastUpdate: DateTime.now(),
      tempHistory: updatedHistory,
    );
  }
}

