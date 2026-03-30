import 'package:flutter/material.dart';
import 'package:achitecture_test/core/module/blecontroller.dart';
// TODO: 앞서 작성한 BleController가 있는 파일을 import 하세요.
import '../../../core/module/blecontroller.dart';
import '../screen/ble_screen.dart';
/// 격자 화면의 하나의 셀(Cell/Node)에 들어갈 BLE 제어 모듈
class BleDashboardNode extends StatefulWidget {
  // 만약 격자 프레임워크에서 노드의 크기나 ID를 주입해준다면 여기서 받습니다.
  // final String nodeId;
  
  const BleDashboardNode({super.key});

  @override
  State<BleDashboardNode> createState() => _BleDashboardNodeState();
}

class _BleDashboardNodeState extends State<BleDashboardNode> {
  // 싱글톤 패턴이나 의존성 주입(DI)으로 컨트롤러를 가져오는 것이 이상적이나, 
  // 현재는 모듈의 독립성을 위해 내부에 인스턴스화합니다.
  final BleController _bleController = BleController();
  final TextEditingController _cmdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 노드가 화면에 그려질 때 상태 변화를 구독합니다.
    _bleController.addListener(_updateUi);
  }

  void _updateUi() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _bleController.removeListener(_updateUi);
    _bleController.dispose();
    _cmdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold 대신 Card나 Container를 사용하여 부모(Grid)가 주는 크기에 맞춥니다.
    return Card(
      color: Colors.black87,
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 노드 헤더 (AppBar 역할 대체)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: _getStatusColor(_bleController.currentState),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "BLE TERMINAL",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                ),
                Text(
                  _bleController.currentState.name.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),

          // 컨트롤 및 상태 표시부 (격자 환경에 맞게 콤팩트하게 압축)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "DATA: ${_bleController.latestData}",
                    style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.play_arrow, color: Colors.green),
                  tooltip: "Connect (Mock)",
                  onPressed: _bleController.currentState == BleState.idle ? _bleController.connect : null,
                ),
                IconButton(
                  icon: const Icon(Icons.stop, color: Colors.red),
                  tooltip: "Disconnect",
                  onPressed: _bleController.currentState == BleState.connected ? _bleController.disconnect : null,
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Colors.grey),

          // 로그 뷰어 (남은 공간을 모두 차지하도록 Expanded 사용)
          Expanded(
            child: Container(
              color: Colors.black,
              child: ListView.builder(
                padding: const EdgeInsets.all(4.0),
                itemCount: _bleController.logs.length,
                itemBuilder: (context, index) {
                  final log = _bleController.logs[index];
                  return Text(
                    log,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11, // 격자 노드 환경에 맞춰 폰트 크기 축소
                      color: log.contains("ERROR") ? Colors.red 
                           : log.contains("RX") ? Colors.cyanAccent 
                           : Colors.grey.shade400,
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

  Color _getStatusColor(BleState state) {
    switch (state) {
      case BleState.idle: return Colors.grey.shade800;
      case BleState.scanning: return Colors.orange.shade700;
      case BleState.connected: return Colors.blue.shade800;
      case BleState.error: return Colors.red.shade800;
    }
  }
}