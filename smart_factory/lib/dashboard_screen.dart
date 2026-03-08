import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'factory_provider.dart';
import 'machine_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final factory = Provider.of<FactoryProvider>(context);
    final machines = factory.machines;

    return Scaffold(
      appBar: AppBar(
        title: const Text("공장 모니터링 대시보드"),
      ),

      body: Row(
  children: [

    // 메인 대시보드 영역
    Expanded(
      flex: 3,
      child: _buildMainGrid(factory),
    ),

    // 우측 로그 패널
    Container(
      width: 300,
      color: Colors.black,
      child: Column(
        children: [

          _buildPanelHeader(
            "실시간 시스템 로그",
            factory.exportReport,
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: factory.eventLogs.length,
              itemBuilder: (context, i) {
                return Text(
                  factory.eventLogs[i],
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontFamily: 'Consolas',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  ],
)
    );
  }
}

Widget _machineCard(BuildContext context, MachineModel machine) {

  return Card(
    color: Colors.black87,
    child: Padding(
      padding: const EdgeInsets.all(12),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            machine.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "온도: ${machine.temperature.toStringAsFixed(1)}°C",
            style: const TextStyle(color: Colors.white),
          ),

          Text(
            "압력: ${machine.pressure.toStringAsFixed(1)}",
            style: const TextStyle(color: Colors.white),
          ),

          const SizedBox(height: 10),

          Text(
            "효율: ${machine.efficiency.toStringAsFixed(1)}%",
            style: const TextStyle(color: Colors.cyanAccent),
          ),

          const Spacer(),

          ElevatedButton(
            onPressed: () {

              // 여기서 상세 분석 다이얼로그 호출
              _showAnalysisReport(context, machine);

            },
            child: const Text("상세 분석"),
          )
        ],
      ),
    ),
  );
}

Widget _buildMainGrid(FactoryProvider factory) {

  final machines = factory.machines;

  return GridView.builder(
    padding: const EdgeInsets.all(16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
    ),
    itemCount: machines.length,
    itemBuilder: (context, index) {

      final machine = machines[index];

      return _machineCard(context, machine);

    },
  );
}

Widget _buildPanelHeader(String title, VoidCallback onExport) {

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    color: Colors.grey[900],
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        IconButton(
          icon: const Icon(Icons.download, color: Colors.white),
          onPressed: onExport,
        ),
      ],
    ),
  );
}

void _showAnalysisReport(BuildContext context, MachineModel machine) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text("${machine.name} 상세 분석 리포트", style: const TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 미니 그래프
            Container(
              height: 100, width: double.infinity, color: Colors.black,
              child: CustomPaint(painter: TrendPainter(machine.tempHistory)),
            ),
            const SizedBox(height: 20),
            _reportRow("현재 온도", "${machine.temperature.toStringAsFixed(1)}°C"),
            _reportRow("평균 효율", "${machine.efficiency.toStringAsFixed(1)}%"),
            _reportRow("상태", machine.status, color: machine.status == "WARNING" ? Colors.red : Colors.green),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("닫기")),
      ],
    ),
  );
}

Widget _reportRow(String label, String value, {Color color = Colors.white}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}