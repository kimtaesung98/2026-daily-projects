import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleController {
  // 상태 관리: Web Automation의 IDLE, DETECTED 등과 같은 개념입니다.
  BluetoothDevice? targetDevice;
  BluetoothCharacteristic? targetCharacteristic;
  StreamSubscription? scanSubscription;

  // HM-10 모듈의 기본 Service와 Characteristic UUID (제조사마다 다를 수 있으나 보통 아래와 같습니다)
  final String hm10ServiceUuid = "0000ffe0-0000-1000-8000-00805f9b34fb";
  final String hm10CharUuid = "0000ffe1-0000-1000-8000-00805f9b34fb";

  /// 1. 스캔 시작 로직
  Future<void> startScan() async {
    print("[BLE INFO] Scanning started...");
    
    // 기존 스캔 중지
    await FlutterBluePlus.stopScan();

    // 스캔 결과 스트림 구독 (Observer 역할)
    scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        // 하드웨어 1단계에서 확인하셨던 HM-10의 이름(예: BT05, HMSoft)을 필터링합니다.
        if (r.device.platformName == "BT05" || r.device.platformName == "HMSoft") {
          print("[BLE INFO] Target Device Found: ${r.device.remoteId}");
          targetDevice = r.device;
          stopScan(); // 타겟을 찾았으니 스캔 중지
          connectToDevice(); // 즉시 연결 시도
          break;
        }
      }
    });

    // 5초간 스캔 수행
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
  }

  /// 2. 스캔 중지 로직
  void stopScan() {
    FlutterBluePlus.stopScan();
    scanSubscription?.cancel();
    print("[BLE INFO] Scanning stopped.");
  }

  /// 3. 디바이스 연결 및 서비스 탐색
  Future<void> connectToDevice() async {
    if (targetDevice == null) return;

    try {
      print("[BLE INFO] Connecting to ${targetDevice!.platformName}...");
      await targetDevice!.connect();
      print("[BLE INFO] Connected successfully!");

      // 서비스 및 캐릭터리스틱 탐색 (GATT 구조 분석)
      List<BluetoothService> services = await targetDevice!.discoverServices();
      for (BluetoothService service in services) {
        if (service.uuid.toString() == hm10ServiceUuid) {
          for (BluetoothCharacteristic char in service.characteristics) {
            if (char.uuid.toString() == hm10CharUuid) {
              targetCharacteristic = char;
              print("[BLE INFO] Target Characteristic found. Subscribing to data stream...");
              subscribeToData();
              break;
            }
          }
        }
      }
    } catch (e) {
      print("[BLE ERROR] Connection failed: $e");
    }
  }

  /// 4. 데이터 수신 (Listen) 및 파싱 (가장 중요한 부분!)
  Future<void> subscribeToData() async {
    if (targetCharacteristic == null) return;

    // 데이터 수신 알림 활성화
    await targetCharacteristic!.setNotifyValue(true);

    // 데이터 스트림 리스닝 (Arduino가 쏘는 데이터를 실시간으로 받음)
    targetCharacteristic!.onValueReceived.listen((value) {
      // value는 [72, 101, 108, 108, 111] 형태의 바이트 배열(List<int>)입니다.
      // 이를 우리가 아는 문자열(String)로 변환합니다.
      String receivedString = utf8.decode(value);
      
      // 로그 체킹 및 송수신 데이터 확인!
      print("[BLE DATA] Raw Hex: $value");
      print("[BLE DATA] Parsed String: $receivedString");
      
      // 여기서부터는 받은 데이터를 UI로 넘겨주는 로직을 작성하면 됩니다.
    });
  }

  /// 5. 데이터 송신 (Flutter -> Arduino)
  Future<void> sendData(String data) async {
    if (targetCharacteristic == null) return;
    
    List<int> bytes = utf8.encode(data);
    await targetCharacteristic!.write(bytes);
    print("[BLE INFO] Sent data: $data");
  }
}