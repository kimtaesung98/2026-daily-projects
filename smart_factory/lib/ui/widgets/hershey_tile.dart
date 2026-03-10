// lib/ui/widgets/hershey_tile.dart
import 'package:flutter/material.dart';
import '../../data/models/machine_model.dart';

class HersheyTile extends StatelessWidget {
  final MachineModel machine;
  const HersheyTile({super.key, required this.machine});

  @override
  Widget build(BuildContext context) {
    // 상태별 색상 (데이터 흐름 캐치용)
    final statusColor = machine.status == "ERROR" ? Colors.red : 
                       machine.status == "WARNING" ? Colors.orange : Colors.cyanAccent;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // 허쉬 초콜릿 다크 브라운 느낌의 배경
        border: Border(left: BorderSide(color: statusColor, width: 6)), // 왼쪽에 상태 바
      ),
      child: Column(
        children: [
          // 1. 기본 정보 열 (ID, 이름, 상태)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(machine.id, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                    Text(machine.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Spacer(),
                // 핵심 수치 (온도)
                Text(
                  "${machine.temperature.toInt()}°C",
                  style: TextStyle(color: statusColor, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Consolas'),
                ),
              ],
            ),
          ),
          
          // 2. 확장 영역 (미래의 기능들이 추가될 곳)
          // 예: 가동률 표시 바
          Container(
            height: 2,
            width: double.infinity,
            color: Colors.white10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("PRESSURE: ${machine.pressure.toInt()} psi", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                Text(machine.status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          // 여기에 추후 [로그 보기], [제어 버튼] 등이 추가될 예정입니다.
        ],
      ),
    );
  }
}