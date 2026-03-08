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

  _subscription = Stream.periodic(const Duration(seconds: 1)).listen((_) {

    final rand = math.Random();

    _machines = _machines.map((machine) {

      double newTemp = 50 + rand.nextDouble() * 50;
      double newPressure = 80 + rand.nextDouble() * 40;

      return machine.copyWith(
        newTemp: newTemp,
        newPressure: newPressure,
      );

    }).toList();

    notifyListeners();

  });
}

  @override
  void dispose() {
    _subscription?.cancel(); // 앱 종료 시 데이터 수집 중단
    super.dispose();
  }
}

class TrendPainter extends CustomPainter {
  final List<double> history;
  TrendPainter(this.history);

  @override
  void paint(Canvas canvas, Size size) {
    if (history.length < 2) return;

    final paint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    double dx = size.width / (history.length - 1);
    
    // 데이터를 화면 높이에 맞춰 정규화 (Min: 50, Max: 100 가정)
    for (int i = 0; i < history.length; i++) {
      double x = i * dx;
      double y = size.height - ((history[i] - 50) / 50 * size.height);
      
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}