import 'dart:async';
import '../domain/interfaces/i_connection_monitor.dart';
import '../core/types/network_status.dart';

class MockConnectionMonitor implements IConnectionMonitor {
  final StreamController<NetworkStatus> _statusController = StreamController<NetworkStatus>.broadcast();
  Timer? _simulationTimer;
  NetworkStatus _currentStatus = NetworkStatus.offline;

  MockConnectionMonitor() {
    _simulateUnstableNetwork();
  }

  @override
  Stream<NetworkStatus> get statusStream => _statusController.stream;

  @override
  NetworkStatus get currentStatus => _currentStatus;

  void _simulateUnstableNetwork() {
    // Start offline, then toggle every 10 seconds to test buffer flushing
    _currentStatus = NetworkStatus.offline;
    _statusController.add(_currentStatus);

    _simulationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _currentStatus = _currentStatus == NetworkStatus.online 
          ? NetworkStatus.offline 
          : NetworkStatus.online;
          
      print("🌐 [Network Monitor]: Status changed to ${_currentStatus.name.toUpperCase()}");
      _statusController.add(_currentStatus);
    });
  }

  void dispose() {
    _simulationTimer?.cancel();
    _statusController.close();
  }
}