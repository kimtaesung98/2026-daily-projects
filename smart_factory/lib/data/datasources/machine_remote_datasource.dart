// lib/data/datasources/machine_remote_datasource.dart
import 'dart:async';
import 'dart:math';

class MachineRemoteDataSource {
  final _random = Random();

  Future<List<Map<String, dynamic>>> fetchRawFactoryData() async {
    // 1. 네트워크 지연 시뮬레이션 (0.5초 ~ 2.5초 사이 랜덤)
    // 실제 웹 통신은 응답 속도가 일정하지 않음을 배웁니다.
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(2000)));

    // 2. 불확실성 시뮬레이션: 15% 확률로 서버 에러 발생
    // 현장에서는 통신 두절이 빈번하므로 이를 대비하는 로직이 필수입니다.
    if (_random.nextInt(100) < 15) {
      throw Exception("서버 연결 실패 (Connection Timeout)");
    }

    // 3. 가상의 JSON 데이터 반환
    return List.generate(6, (i) => {
      "id": "LINE-B$i",
      "name": "생산 공정 $i호기",
      "temp": 30.0 + _random.nextDouble() * 70, // 30~100도
      "press": 80.0 + _random.nextDouble() * 50, // 80~130압력
      "status": "ONLINE"
    });
  }
}