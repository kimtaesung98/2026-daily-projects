import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart'; // 패키지 임포트

void main() {
  runApp(const PhoneSensorApp());
}

// 1. 데이터 모델 (동일)
class SensorData {
  final double gyroX, gyroY, gyroZ;
  final double accelX, accelY, accelZ;

  SensorData({
    required this.gyroX, required this.gyroY, required this.gyroZ,
    required this.accelX, required this.accelY, required this.accelZ,
  });
}

// 2. 개선된 데이터 서비스 모듈 (실제 센서 연결)
class SensorDataService {
  final StreamController<SensorData> _controller = StreamController<SensorData>.broadcast();
  
  // sensors_plus의 스트림을 관리할 구독 변수
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  StreamSubscription<AccelerometerEvent>? _accelSub;

  // 임시 저장용 변수
  double _gx = 0, _gy = 0, _gz = 0;
  double _ax = 0, _ay = 0, _az = 0;

  Stream<SensorData> get sensorStream => _controller.stream;

  void startReceiving() {
    // 각속도(Gyroscope) 구독
    _gyroSub = gyroscopeEventStream().listen((GyroscopeEvent event) {
      _gx = event.x; _gy = event.y; _gz = event.z;
      _emitCombinedData();
    });

    // 가속도(Accelerometer) 구독
    _accelSub = accelerometerEventStream().listen((AccelerometerEvent event) {
      _ax = event.x; _ay = event.y; _az = event.z;
      _emitCombinedData();
    });
  }

  void _emitCombinedData() {
    _controller.add(SensorData(
      gyroX: _gx, gyroY: _gy, gyroZ: _gz,
      accelX: _ax, accelY: _ay, accelZ: _az,
    ));
  }

  void stopReceiving() {
    _gyroSub?.cancel();
    _accelSub?.cancel();
  }

  void dispose() {
    stopReceiving();
    _controller.close();
  }
}

// 3. UI 부분 (기존과 거의 동일, 서비스 모듈만 활용)
class PhoneSensorApp extends StatelessWidget {
  const PhoneSensorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const SensorDashboard(),
    );
  }
}

class SensorDashboard extends StatefulWidget {
  const SensorDashboard({super.key});

  @override
  State<SensorDashboard> createState() => _SensorDashboardState();
}

class _SensorDashboardState extends State<SensorDashboard> {
  final SensorDataService _service = SensorDataService();
  SensorData _data = SensorData(gyroX: 0, gyroY: 0, gyroZ: 0, accelX: 0, accelY: 0, accelZ: 0);
  bool _isLive = false;

  void _toggle() {
    setState(() {
      if (_isLive) {
        _service.stopReceiving();
      } else {
        _service.startReceiving();
      }
      _isLive = !_isLive;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Sensor Real-time')),
      body: StreamBuilder<SensorData>(
        stream: _service.sensorStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) _data = snapshot.data!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildGroup('Gyroscope (rad/s)', [
                  _tile('X', _data.gyroX, Colors.red),
                  _tile('Y', _data.gyroY, Colors.green),
                  _tile('Z', _data.gyroZ, Colors.blue),
                ]),
                const SizedBox(height: 20),
                _buildGroup('Accelerometer (m/s²)', [
                  _tile('X', _data.accelX, Colors.orange),
                  _tile('Y', _data.accelY, Colors.teal),
                  _tile('Z', _data.accelZ, Colors.purple),
                ]),
                const SizedBox(height: 30),
                FloatingActionButton.extended(
                  onPressed: _toggle,
                  label: Text(_isLive ? 'STOP' : 'START LIVE'),
                  icon: Icon(_isLive ? Icons.pause : Icons.play_arrow),
                  backgroundColor: _isLive ? Colors.redAccent : Colors.indigo,
                )
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _tile(String label, double val, Color color) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, child: Text(label, style: const TextStyle(color: Colors.white))),
        title: Text(val.toStringAsFixed(4), style: const TextStyle(fontFamily: 'monospace', fontSize: 20)),
      ),
    );
  }
}