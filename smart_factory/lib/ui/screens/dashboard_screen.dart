// lib/ui/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/factory_provider.dart';
import '../widgets/hershey_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final factory = context.watch<FactoryProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text("SMART FACTORY INSPECTOR", style: TextStyle(fontSize: 14)),
        centerTitle: false,
        actions: [
          // 최적화 수치 실시간 표시 (005 핵심 검증)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                "OPT: ${factory.optimizationRate}%",
                style: const TextStyle(color: Colors.greenAccent, fontFamily: 'Consolas'),
              ),
            ),
          ),
        ],
      ),
      body: _buildResponsiveBody(factory),
    );
  }

  Widget _buildResponsiveBody(FactoryProvider factory) {
    // 데이터 로딩 중이고 리스트가 비어있을 때
    if (factory.isLoading && factory.machines.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 데이터가 아예 없을 때 (에러 포함)
    if (factory.machines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("데이터 없음", style: TextStyle(color: Colors.white)),
            TextButton(onPressed: () => factory.refreshData(), child: const Text("새로고침")),
          ],
        ),
      );
    }

    // [허쉬 초콜릿 리스트] 데이터가 확실히 노출되는 구조
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: factory.machines.length,
      itemBuilder: (context, index) => HersheyTile(machine: factory.machines[index]),
    );
  }
}