import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../domain/interfaces/i_connection_monitor.dart';
import '../core/types/network_status.dart';
import 'wear_connectivity_service.dart';

class ConnectionMonitor implements IConnectionMonitor {
  final StreamController<NetworkStatus> _statusController =
      StreamController<NetworkStatus>.broadcast();
  final Connectivity _connectivity = Connectivity();
  final WearConnectivityService _wearConnectivityService;

  NetworkStatus _currentStatus = NetworkStatus.offline;
  bool _wearConnected = false;
  bool _phoneNetworkReady = false;
  bool _isWifi = false;
  bool _edgeConnected = false;
  String _connectedWatchName = 'Disconnected';
  String _connectedWatchModel = 'Unknown';
  String _userId;

  ConnectionMonitor({
    required WearConnectivityService wearConnectivityService,
    String userId = 'dev-user-001',
  })  : _wearConnectivityService = wearConnectivityService,
        _userId = userId {
    _connectivity.onConnectivityChanged.listen(_onPhoneConnectivityChanged);
    _wearConnectivityService.stateStream.listen((state) {
      _wearConnected = state.isConnected;
      _connectedWatchName = state.watchName;
      _connectedWatchModel = state.watchModel;
      _recalculateStatus();
    });
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final results = await _connectivity.checkConnectivity();
    _onPhoneConnectivityChanged(results);
  }

  void _onPhoneConnectivityChanged(List<ConnectivityResult> results) {
    _phoneNetworkReady = !results.contains(ConnectivityResult.none);
    _isWifi = results.contains(ConnectivityResult.wifi);
    if (!_phoneNetworkReady) {
      _edgeConnected = false;
    }
    _recalculateStatus();
  }

  @override
  void updateEdgeConnection(bool isConnected) {
    _edgeConnected = isConnected;
    _recalculateStatus();
  }

  void _recalculateStatus() {
    if (!_wearConnected || !_phoneNetworkReady) {
      _currentStatus = NetworkStatus.offline;
    } else if (_wearConnected && _phoneNetworkReady && !_edgeConnected) {
      _currentStatus = NetworkStatus.searching;
    } else {
      _currentStatus = NetworkStatus.online;
    }
    _statusController.add(_currentStatus);
  }

  @override
  Stream<NetworkStatus> get statusStream => _statusController.stream;

  @override
  NetworkStatus get currentStatus => _currentStatus;

  @override
  bool get isWearConnected => _wearConnected;

  @override
  bool get isEdgeConnected => _edgeConnected;

  @override
  String get connectedWatchName => _connectedWatchName;

  @override
  String get connectedWatchModel => _connectedWatchModel;

  @override
  String get currentUserId => _userId;

  @override
  bool get isWifiConnection => _isWifi;

  @override
  void updateUserId(String userId) {
    _userId = userId;
    _recalculateStatus();
  }
}