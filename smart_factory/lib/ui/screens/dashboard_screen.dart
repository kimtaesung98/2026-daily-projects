// lib/ui/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/factory_provider.dart';
import '../../data/models/machine_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final factory = context.watch<FactoryProvider>();

    return Scaffold(
      backgroundColor: Colors.black, // 배경은 완전한 블랙으로 데이터 집중도 향상
      body: Column(
        children: [
          // [검증 섹션] 데이터 흐름 및 최적화 수치 표시
          _buildPerformanceHeader(factory),
          
          // [초콜릿 격자] 기계 상태 표시부
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(2), // 조각 사이의 아주 좁은 간격
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,     // 윈도우 기준 한 줄에 4개 (정사각형 유지)
                crossAxisSpacing: 2,   // 초콜릿 구분선 느낌
                mainAxisSpacing: 2,
                childAspectRatio: 1.0, // 완벽한 사각형 구조
              ),
              itemCount: factory.machines.length,
              itemBuilder: (context, index) => _buildChocolateTile(factory.machines[index]),
            ),
          ),
        ],
      ),
    );
  }
  // DashboardScreen 내부 메서드
  Widget _buildChocolateTile(MachineModel machine) {
    // 상태에 따른 배경색 결정 (데이터 흐름 캐치를 위한 시각 장치)
    Color statusColor;
    switch (machine.status) {
      case "ERROR": statusColor = Colors.red[900]!; break;
      case "WARNING": statusColor = Colors.orange[900]!; break;
      default: statusColor = Colors.blueGrey[900]!;
    }

    return Container(
      color: statusColor,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 기계 ID (최소 정보)
          Text(machine.id, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          const SizedBox(height: 10),
          // 핵심 데이터 (크게 표시)
          Text(
            "${machine.temperature.toInt()}",
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'Consolas'),
          ),
          const Text("°C", style: TextStyle(color: Colors.white70, fontSize: 12)),
          const Spacer(),
          // 현재 상태 텍스트
          Text(
            machine.status,
            style: const TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.5),
          ),
        ],
      ),
    );
  }
  // 상단 성능 검사 바
  Widget _buildPerformanceHeader(FactoryProvider factory) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[900],
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("FLOW INSPECTION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(
              "FETCH: ${factory.rawFetchCount} | REFRESH: ${factory.uiUpdateCount} | OPT: ${factory.optimizationRate}%",
              style: const TextStyle(color: Colors.cyanAccent, fontFamily: 'Consolas', fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}