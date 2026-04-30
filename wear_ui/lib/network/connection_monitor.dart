import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../domain/interfaces/i_connection_monitor.dart';
import '../core/types/network_status.dart';

class ConnectionMonitor implements IConnectionMonitor {
  final StreamController<NetworkStatus> _statusController = StreamController<NetworkStatus>.broadcast();
  final Connectivity _connectivity = Connectivity();
  
  NetworkStatus _currentStatus = NetworkStatus.offline;

  ConnectionMonitor() {
    _connectivity.onConnectivityChanged.listen(_updateState);
  }

  void _updateState(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      _currentStatus = NetworkStatus.offline;
    } else {
      // 네트워크는 연결됨 -> 이제 Edge Client가 이 신호를 받아 MQTT 접속을 시도해야 함
      _currentStatus = NetworkStatus.searching;
    }
    _statusController.add(_currentStatus);
  }

  @override
  Stream<NetworkStatus> get statusStream => _statusController.stream;

  @override
  NetworkStatus get currentStatus => _currentStatus;
}