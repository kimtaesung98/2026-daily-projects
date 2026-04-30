import 'dart:async';
import '../../core/types/network_status.dart';

abstract class IConnectionMonitor {
  /// 네트워크 상태 변화를 감지하는 스트림
  Stream<NetworkStatus> get statusStream;
  
  /// 현재 네트워크 상태 조회
  NetworkStatus get currentStatus;

  /// Wear OS <-> Phone 링크 연결 상태
  bool get isWearConnected;

  /// Phone <-> Edge(MQTT) 링크 연결 상태
  bool get isEdgeConnected;

  /// 현재 연결된 워치 이름
  String get connectedWatchName;

  /// 현재 연결된 워치 모델명
  String get connectedWatchModel;

  /// 현재 사용자 식별자
  String get currentUserId;

  /// 현재 Phone 네트워크가 Wi-Fi인지 여부
  bool get isWifiConnection;

  /// Edge(MQTT) 연결 상태를 모니터에 반영합니다.
  void updateEdgeConnection(bool isConnected);

  /// 사용자 식별자를 런타임에 갱신합니다.
  void updateUserId(String userId);
}