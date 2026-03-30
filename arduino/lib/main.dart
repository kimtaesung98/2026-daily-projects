import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const DevApp());
}

class DevApp extends StatelessWidget {
  const DevApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Dev Dashboard',
      theme: ThemeData.dark(), // 개발자 감성의 다크 모드
      home: const DevDashboard(),
    );
  }
}

// ==========================================
// [BACKEND] BLE Controller (Logic & State)
// ==========================================
enum BleState { idle, scanning, connected, error }

class BleController extends ChangeNotifier {
  BleState _currentState = BleState.idle;
  BleState get currentState => _currentState;

  bool isMockMode = true; // 에뮬레이터 환경이므로 기본값 True

  // 수신된 최신 데이터와 누적 로그
  String latestData = "NO DATA";
  List<String> logs = [];

  Timer? _mockTimer;

  void _addLog(String message) {
    final time = DateTime.now().toString().split(' ')[1].substring(0, 8);
    logs.insert(0, "[$time] $message"); // 최신 로그가 위에 오도록
    notifyListeners();
  }

  // 연결 시도 (Mock 또는 Real)
  void connect() async {
    _currentState = BleState.scanning;
    _addLog("Starting scan... (Mock Mode: $isMockMode)");
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2)); // 스캔 딜레이 모방

    if (isMockMode) {
      _currentState = BleState.connected;
      _addLog("Connected to MOCK_DEVICE (HM-10 Dummy)");
      _startMockDataStream();
    } else {
      // TODO: 추후 실기기 준비 시 flutter_blue_plus 로직 연동
      _addLog("[ERROR] Real hardware scan is not implemented yet.");
      _currentState = BleState.error;
    }
    notifyListeners();
  }

  // 연결 해제
  void disconnect() {
    _mockTimer?.cancel();
    _currentState = BleState.idle;
    latestData = "NO DATA";
    _addLog("Disconnected.");
    notifyListeners();
  }

  // 데이터 송신 (Flutter -> Device)
  void sendData(String data) {
    if (_currentState != BleState.connected) {
      _addLog("Cannot send: Device not connected.");
      return;
    }
    _addLog("TX (Send): $data");
    // 실기기일 경우 여기서 characteristic.write() 호출
  }

  // Mock 데이터 스트림 생성 (Arduino 역할을 대신함)
  int _mockCounter = 0;
  void _startMockDataStream() {
    _mockTimer?.cancel();
    _mockTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _mockCounter++;
      String receivedRaw = "DATA:$_mockCounter";
      latestData = receivedRaw;
      _addLog("RX (Receive): $receivedRaw");
      notifyListeners();
    });
  }

  // 상태 초기화 (메모리 누수 방지)
  @override
  void dispose() {
    _mockTimer?.cancel();
    super.dispose();
  }
}

// ==========================================
// [FRONTEND] Developer UI Dashboard
// ==========================================
class DevDashboard extends StatefulWidget {
  const DevDashboard({super.key});

  @override
  State<DevDashboard> createState() => _DevDashboardState();
}

class _DevDashboardState extends State<DevDashboard> {
  final BleController _bleController = BleController();
  final TextEditingController _cmdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 상태 변경 시 UI 업데이트 바인딩
    _bleController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _bleController.dispose();
    _cmdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Dev Console', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black87,
        actions: [
          Row(
            children: [
              const Text("Mock Mode"),
              Switch(
                value: _bleController.isMockMode,
                onChanged: (val) {
                  setState(() {
                    _bleController.isMockMode = val;
                    _bleController.disconnect();
                  });
                },
              ),
            ],
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Status Panel (상태 모니터링)
          Container(
            padding: const EdgeInsets.all(16),
            color: _getStatusColor(_bleController.currentState),
            child: Text(
              "STATE: ${_bleController.currentState.name.toUpperCase()}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),

          // 2. Data Panel (수신 데이터 파싱 결과)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                const Text("LATEST SENSOR DATA", style: TextStyle(color: Colors.grey)),
                Text(
                  _bleController.latestData,
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                ),
              ],
            ),
          ),
          const Divider(),

          // 3. Control Panel (조작부)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _bleController.currentState == BleState.idle ? _bleController.connect : null,
                  icon: const Icon(Icons.bluetooth_searching),
                  label: const Text("CONNECT"),
                ),
                ElevatedButton.icon(
                  onPressed: _bleController.currentState == BleState.connected ? _bleController.disconnect : null,
                  icon: const Icon(Icons.bluetooth_disabled),
                  label: const Text("DISCONNECT"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                ),
              ],
            ),
          ),

          // 4. Command Input (데이터 송신 테스트)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cmdController,
                    decoration: const InputDecoration(
                      hintText: 'Command to send (e.g. LED_ON)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_cmdController.text.isNotEmpty) {
                      _bleController.sendData(_cmdController.text);
                      _cmdController.clear();
                    }
                  },
                  child: const Text("SEND"),
                )
              ],
            ),
          ),

          const Divider(),

          // 5. Raw Log Terminal (실시간 터미널 뷰)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text("TERMINAL LOGS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Expanded(
            child: Container(
              color: Colors.black,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _bleController.logs.length,
                itemBuilder: (context, index) {
                  final log = _bleController.logs[index];
                  return Text(
                    log,
                    style: TextStyle(
                      fontFamily: 'monospace', // 터미널 감성의 폰트
                      color: log.contains("ERROR") ? Colors.red 
                           : log.contains("RX") ? Colors.cyanAccent 
                           : log.contains("TX") ? Colors.orangeAccent 
                           : Colors.green,
                      fontSize: 13,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 상태에 따른 배경색 반환 함수
  Color _getStatusColor(BleState state) {
    switch (state) {
      case BleState.idle: return Colors.grey.shade800;
      case BleState.scanning: return Colors.orange;
      case BleState.connected: return Colors.blue.shade800;
      case BleState.error: return Colors.red;
    }
  }
}