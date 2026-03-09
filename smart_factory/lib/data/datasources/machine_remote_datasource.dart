import 'dart:async';
import 'dart:math';

class MachineRemoteDataSource {

  Future<List<Map<String, dynamic>>> fetchRawFactoryData() async {

    final rand = Random();

    await Future.delayed(
      Duration(milliseconds: 500 + rand.nextInt(1500))
    );

    if (rand.nextInt(10) == 0) {
      throw Exception("네트워크 불안정: 서버 응답 없음 (503 Error)");
    }

    return List.generate(5, (i) => {
      "id": "MC-$i",
      "name": "공정 라인 $i",
      "temp": 40.0 + rand.nextDouble() * 60,
      "press": 90.0 + rand.nextDouble() * 30,
      "status": "ONLINE"
    });
  }
}