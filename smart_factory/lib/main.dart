import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'machine_model.dart';
import 'factory_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => FactoryProvider()..startMonitoring(), // 앱 시작 시 모니터링 개시
      child: const MaterialApp(home: FactoryDashboard()),
    ),
  );
}

class FactoryDashboard extends StatelessWidget {
  const FactoryDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final factory = context.watch<FactoryProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // 공장 느낌의 다크 테마
      appBar: AppBar(
        title: const Text("SMART FACTORY REAL-TIME MONITOR"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 상단 요약 보고서 영역
            _buildSummaryHeader(factory.machines),
            const SizedBox(height: 20),
            // 실시간 기계 상태 카드 그리드
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
                ),
                itemCount: factory.machines.length,
                itemBuilder: (context, index) => _buildMachineCard(factory.machines[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 기계별 데이터 카드
  Widget _buildMachineCard(MachineModel machine) {
    bool isWarning = machine.status == "WARNING";
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWarning ? Colors.redAccent.withOpacity(0.2) : Colors.grey[900],
        border: Border.all(color: isWarning ? Colors.red : Colors.blueAccent),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(machine.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text("TEMP: ${machine.temperature.toStringAsFixed(1)}°C", 
               style: TextStyle(color: isWarning ? Colors.red : Colors.cyan, fontSize: 18)),
          Text("EFFICIENCY: ${machine.efficiency.toStringAsFixed(1)}%", 
               style: const TextStyle(color: Colors.greenAccent)),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: machine.efficiency / 100,
            backgroundColor: Colors.white10,
            color: isWarning ? Colors.red : Colors.blue,
          ),
        ],
      ),
    );
  }

  // 상단 요약 데이터 요약
  Widget _buildSummaryHeader(List<MachineModel> machines) {
    if (machines.isEmpty) return const SizedBox();
    double avgEff = machines.map((m) => m.efficiency).reduce((a, b) => a + b) / machines.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("공장 전체 평균 효율", style: TextStyle(color: Colors.white, fontSize: 16)),
          Text("${avgEff.toStringAsFixed(2)}%", 
               style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}