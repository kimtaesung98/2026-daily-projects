import 'dart:async';
import '../../core/types/network_status.dart';

abstract class IConnectionMonitor {
  /// 네트워크 상태 변화를 감지하는 스트림
  Stream<NetworkStatus> get statusStream;
  
  /// 현재 네트워크 상태 조회
  NetworkStatus get currentStatus;
}