import 'dart:async';
import 'package:flutter/material.dart';

// ==========================================
// [BACKEND] BLE Controller (Logic & State)
// ==========================================
enum BleState { idle, scanning, connected, error }

class BleController extends ChangeNotifier {
  BleState _currentState = BleState.idle;
  BleState get currentState => _currentState;

  bool isMockMode = true; // 실기기 연결 전이므로 Mock 모드 켬
  String latestData = "NO DATA";
  List<String> logs = [];
  Timer? _mockTimer;

  void _addLog(String message) {
    final time = DateTime.now().toString().split(' ')[1].substring(0, 8);
    logs.insert(0, "[$time] $message");
    notifyListeners();
  }

  void connect() async {
    _currentState = BleState.scanning;
    _addLog("Starting scan... (Mock Mode: $isMockMode)");
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    if (isMockMode) {
      _currentState = BleState.connected;
      _addLog("Connected to MOCK_DEVICE (HM-10 Dummy)");
      _startMockDataStream();
    } else {
      _addLog("[ERROR] Real hardware scan needs flutter_blue_plus.");
      _currentState = BleState.error;
    }
    notifyListeners();
  }

  void disconnect() {
    _mockTimer?.cancel();
    _currentState = BleState.idle;
    latestData = "NO DATA";
    _addLog("Disconnected.");
    notifyListeners();
  }

  void sendData(String data) {
    if (_currentState != BleState.connected) {
      _addLog("Cannot send: Device not connected.");
      return;
    }
    _addLog("TX (Send): $data");
  }

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

  @override
  void dispose() {
    _mockTimer?.cancel();
    super.dispose();
  }
}

// ==========================================
// [FRONTEND] BLE Destination Screen
// ==========================================
class BleScreen extends StatefulWidget {
  const BleScreen({super.key});

  @override
  State<BleScreen> createState() => _BleScreenState();
}

class _BleScreenState extends State<BleScreen> {
  final BleController _bleController = BleController();
  final TextEditingController _cmdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bleController.addListener(() {
      if (mounted) setState(() {});
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
      backgroundColor: const Color(0xFF1A1A2E), // 개발자 감성의 다크 배경
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: const Text('BLE Dev Console', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white), // 뒤로가기 버튼 흰색
        actions: [
          Row(
            children: [
              const Text("Mock", style: TextStyle(color: Colors.white70, fontSize: 12)),
              Switch(
                value: _bleController.isMockMode,
                activeColor: Colors.deepOrange,
                onChanged: (val) {
                  _bleController.isMockMode = val;
                  _bleController.disconnect();
                },
              ),
            ],
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. 상태 표시 패널
          Container(
            padding: const EdgeInsets.all(12),
            color: _getStatusColor(_bleController.currentState),
            child: Text(
              "STATUS: ${_bleController.currentState.name.toUpperCase()}",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
              textAlign: TextAlign.center,
            ),
          ),

          // 2. 최신 데이터 뷰어
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const Text("LATEST SENSOR DATA", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                Text(
                  _bleController.latestData,
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                ),
              ],
            ),
          ),

          // 3. 제어 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _bleController.currentState == BleState.idle ? _bleController.connect : null,
                icon: const Icon(Icons.link),
                label: const Text("CONNECT"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              ),
              ElevatedButton.icon(
                onPressed: _bleController.currentState == BleState.connected ? _bleController.disconnect : null,
                icon: const Icon(Icons.link_off),
                label: const Text("DISCONNECT"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),

          // 4. 터미널 로그 뷰어 (Expanded로 남은 공간 꽉 채움)
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.black,
            child: const Text("RAW TERMINAL", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Container(
              color: Colors.black,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                itemCount: _bleController.logs.length,
                itemBuilder: (context, index) {
                  final log = _bleController.logs[index];
                  return Text(
                    log,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: log.contains("ERROR") ? Colors.redAccent 
                           : log.contains("RX") ? Colors.cyanAccent 
                           : log.contains("TX") ? Colors.orangeAccent 
                           : Colors.green,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          ),

          // 5. 명령어 전송 입력부
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cmdController,
                    style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                    decoration: const InputDecoration(
                      hintText: 'Type command...',
                      hintStyle: TextStyle(color: Colors.white38),
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepOrange),
                  onPressed: () {
                    if (_cmdController.text.isNotEmpty) {
                      _bleController.sendData(_cmdController.text);
                      _cmdController.clear();
                    }
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BleState state) {
    switch (state) {
      case BleState.idle: return Colors.grey.shade800;
      case BleState.scanning: return Colors.orange.shade800;
      case BleState.connected: return Colors.blue.shade800;
      case BleState.error: return Colors.red.shade900;
    }
  }
}