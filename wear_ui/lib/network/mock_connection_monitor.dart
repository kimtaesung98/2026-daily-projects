import 'dart:async';
import '../domain/interfaces/i_connection_monitor.dart';
import '../core/types/network_status.dart';

class MockConnectionMonitor implements IConnectionMonitor {
  final StreamController<NetworkStatus> _statusController =
      StreamController<NetworkStatus>.broadcast();
  Timer? _simulationTimer;
  NetworkStatus _currentStatus = NetworkStatus.offline;
  bool _isWearConnected = false;
  bool _isEdgeConnected = false;
  final String _watchName = 'Mock Wear';
  String _userId = 'mock-user';
  bool _isWifiConnection = true;

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
    _isWearConnected = false;
    _isEdgeConnected = false;
    _statusController.add(_currentStatus);

    _simulationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _currentStatus = _currentStatus == NetworkStatus.online
          ? NetworkStatus.offline
          : NetworkStatus.online;
      _isWearConnected = _currentStatus == NetworkStatus.online;
      _isEdgeConnected = _currentStatus == NetworkStatus.online;

      print("🌐 [Network Monitor]: Status changed to ${_currentStatus.name.toUpperCase()}");
      _statusController.add(_currentStatus);
    });
  }

  void dispose() {
    _simulationTimer?.cancel();
    _statusController.close();
  }

  @override
  void updateEdgeConnection(bool isConnected) {
    _isEdgeConnected = isConnected;
    _currentStatus = (_isWearConnected && _isEdgeConnected)
        ? NetworkStatus.online
        : NetworkStatus.offline;
    _statusController.add(_currentStatus);
  }

  @override
  bool get isWearConnected => _isWearConnected;

  @override
  bool get isEdgeConnected => _isEdgeConnected;

  @override
  String get connectedWatchName => _watchName;

  @override
  String get connectedWatchModel => 'Mock Model';

  @override
  String get currentUserId => _userId;

  @override
  bool get isWifiConnection => _isWifiConnection;

  @override
  void updateUserId(String userId) {
    _userId = userId;
  }
}