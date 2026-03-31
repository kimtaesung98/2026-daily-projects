import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/gridprovider.dart';
import '../domain/node03/detailscreen.dart';

class GridScreen extends StatelessWidget {
  const GridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GridProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('System Nodes Dashboard')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.2,
        ),
        itemCount: provider.nodes.length,
        itemBuilder: (context, index) {
          final node = provider.nodes[index];

          final (String title, String subtitle, Widget destination) = switch (node) {
            
            // 1. 모델에 데이터가 아예 없는 경우: UI에서 고정된 텍스트를 할당합니다.
            InfoDetailScreen _ => (
              'System Info', 
              'Static Page', 
              const InfoDetailScreen() // index를 넘길 필요도 없음
            ),
            
            // 2. 엄청나게 많은 데이터를 가진 모델의 경우: 필요한 것만 골라서 그리드 요약본에 씁니다.
            // ComplexNodeModel n => (
            //   n.serverName, 
            //   'Firewall: ${n.isFirewallActive ? "ON" : "OFF"} | Temp: ${n.cpuTemperatures['Core1']}°C', 
            //   ComplexDetailScreen(nodeIndex: index) // 디테일 화면으로 진입
            // ),
            
            _ => ('Unknown', '-', const SizedBox()),
          };
        },
      ),
    );
  }
}