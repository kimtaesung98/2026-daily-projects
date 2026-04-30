import 'dart:async';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class WearConnectionState {
  final bool isConnected;
  final String watchName;
  final String watchModel;

  const WearConnectionState({
    required this.isConnected,
    required this.watchName,
    required this.watchModel,
  });
}

class WearConnectivityService {
  static const MethodChannel _channel = MethodChannel(
    'wear_ui/wear_connectivity',
  );

  final Connectivity _connectivity = Connectivity();
  final StreamController<WearConnectionState> _controller =
      StreamController<WearConnectionState>.broadcast();

  WearConnectionState _current = const WearConnectionState(
    isConnected: false,
    watchName: 'Disconnected',
    watchModel: 'Unknown',
  );

  Stream<WearConnectionState> get stateStream => _controller.stream;
  WearConnectionState get currentState => _current;

  WearConnectivityService() {
    _bootstrap();
    _connectivity.onConnectivityChanged.listen((_) => _refreshState());
  }

  Future<void> _bootstrap() async {
    await _refreshState();
  }

  Future<void> _refreshState() async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'getWearConnection',
      );
      final isConnected = result?['connected'] == true;
      final watchName = (result?['name'] as String?) ?? 'Wear OS';
      final watchModel = (result?['model'] as String?) ?? 'Unknown Wear';
      _emit(
        isConnected: isConnected,
        watchName: watchName,
        watchModel: watchModel,
      );
      return;
    } catch (_) {
      // Fallback: when native bridge is not wired yet, infer from phone network.
    }

    final network = await _connectivity.checkConnectivity();
    final online = !network.contains(ConnectivityResult.none);
    _emit(
      isConnected: online,
      watchName: online ? 'Wear OS (Fallback)' : 'Disconnected',
      watchModel: online ? 'Fallback Model' : 'Unknown',
    );
  }

  void _emit({
    required bool isConnected,
    required String watchName,
    required String watchModel,
  }) {
    _current = WearConnectionState(
      isConnected: isConnected,
      watchName: watchName,
      watchModel: watchModel,
    );
    _controller.add(_current);
  }
}
