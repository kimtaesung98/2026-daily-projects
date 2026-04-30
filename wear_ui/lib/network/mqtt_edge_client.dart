import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../domain/interfaces/i_edge_client.dart';
import '../domain/entities/sensor_packet.dart';
import '../core/types/network_status.dart';

class MqttEdgeClient implements IEdgeClient {
  late MqttServerClient _client;
  bool _isConnected = false;
  
  // TODO: 실제 Edge 디바이스(또는 MQTT 브로커)의 IP 주소로 변경하세요.
  final String brokerAddress = '192.168.1.100'; 
  final String topic = 'edge/sensors/data';
  final String clientId = 'flutter_sensor_bridge_${DateTime.now().millisecondsSinceEpoch}';


  MqttEdgeClient() {
    _initClient();
  }

  void _initClient() {
    _client = MqttServerClient(brokerAddress, clientId);
    _client.port = 1883; // 기본 MQTT 포트
    _client.logging(on: false);
    _client.keepAlivePeriod = 20;
    
    
    // 자동 재연결 설정
    _client.autoReconnect = true;
    _client.onDisconnected = () {
      print('⚠️ [MQTT]: Edge Device와 연결이 끊어졌습니다.');
      _isConnected = false;
    };
    _client.onConnected = () {
      print('✅ [MQTT]: Edge Device에 성공적으로 연결되었습니다.');
      _isConnected = true;
    };
    _client.onConnected = () {
      _updateSystemStatus(NetworkStatus.online);
    };
    _client.onDisconnected = () {
      _updateSystemStatus(NetworkStatus.reconnecting);
    };
    _client.onAutoReconnect = () => _updateSystemStatus(NetworkStatus.connecting);
  }

  void _updateSystemStatus(NetworkStatus status) {
    // Locator를 통해 ConnectionMonitor의 상태를 강제로 업데이트하거나 
    // 별도의 상태 스트림을 통해 UI에 알림을 보냅니다.
    print("📢 [Network Logic]: 장치 연결 상태 변경 -> ${status.name}");
  }

  Future<void> _connectIfNeeded() async {
    if (_isConnected && _client.connectionStatus!.state == MqttConnectionState.connected) {
      return;
    }

    try {
      print('🔄 [MQTT]: 브로커($brokerAddress)에 연결 시도 중...');
      await _client.connect();
    } catch (e) {
      _client.disconnect();
      throw Exception('MQTT 연결 실패: $e');
    }
  }

  @override
  Future<void> sendBatch(List<SensorPacket> packets) async {
    if (packets.isEmpty) return;

    // 1. 연결 상태 확인 및 재연결
    await _connectIfNeeded();

    // 2. 패킷 리스트를 JSON 배열 문자열로 변환
    final List<Map<String, dynamic>> jsonList = packets.map((p) => p.toJson()).toList();
    final String jsonPayload = jsonEncode({'batch': jsonList});

    // 3. MQTT 페이로드 빌더 생성
    final builder = MqttClientPayloadBuilder();
    builder.addString(jsonPayload);

    // 4. 데이터 발행 (QoS 1: 최소 한 번 전송 보장)
    print("🚀 [MQTT]: ${packets.length}개의 센서 데이터를 Edge로 전송합니다.");
    final int messageId = _client.publishMessage(
      topic,
      MqttQos.atLeastOnce,
      builder.payload!,
    );

    if (messageId == 0) {
      // 0이 반환되면 발행 실패를 의미함 (버퍼 복구를 위해 Exception 발생)
      throw Exception('MQTT 메시지 발행 실패');
    }
  }
}