import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

enum TransmissionSpeed {
  realTime,
  oneSecond,
  threeSeconds,
  fiveSeconds,
}

class TransmissionPolicyState {
  final TransmissionSpeed speed;
  final bool wifiOnly;
  final String adminUserId;
  final String adminPassword;

  const TransmissionPolicyState({
    required this.speed,
    required this.wifiOnly,
    required this.adminUserId,
    required this.adminPassword,
  });

  Duration get flushInterval {
    switch (speed) {
      case TransmissionSpeed.realTime:
        return Duration.zero;
      case TransmissionSpeed.oneSecond:
        return const Duration(seconds: 1);
      case TransmissionSpeed.threeSeconds:
        return const Duration(seconds: 3);
      case TransmissionSpeed.fiveSeconds:
        return const Duration(seconds: 5);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'speed': speed.name,
      'wifiOnly': wifiOnly,
      'adminUserId': adminUserId,
      'adminPassword': adminPassword,
    };
  }

  TransmissionPolicyState copyWith({
    TransmissionSpeed? speed,
    bool? wifiOnly,
    String? adminUserId,
    String? adminPassword,
  }) {
    return TransmissionPolicyState(
      speed: speed ?? this.speed,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      adminUserId: adminUserId ?? this.adminUserId,
      adminPassword: adminPassword ?? this.adminPassword,
    );
  }

  static TransmissionPolicyState fromPrefs(SharedPreferences prefs) {
    final speedName = prefs.getString('policy.speed') ?? TransmissionSpeed.realTime.name;
    final speed = TransmissionSpeed.values.firstWhere(
      (e) => e.name == speedName,
      orElse: () => TransmissionSpeed.realTime,
    );
    return TransmissionPolicyState(
      speed: speed,
      wifiOnly: prefs.getBool('policy.wifiOnly') ?? false,
      adminUserId: prefs.getString('policy.adminUserId') ?? 'dev-user-001',
      adminPassword: prefs.getString('policy.adminPassword') ?? '1234',
    );
  }
}

class TransmissionPolicy {
  final StreamController<TransmissionPolicyState> _controller =
      StreamController<TransmissionPolicyState>.broadcast();
  TransmissionPolicyState _state = const TransmissionPolicyState(
    speed: TransmissionSpeed.realTime,
    wifiOnly: false,
    adminUserId: 'dev-user-001',
    adminPassword: '1234',
  );

  TransmissionPolicyState get state => _state;
  Stream<TransmissionPolicyState> get stream => _controller.stream;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _state = TransmissionPolicyState.fromPrefs(prefs);
    _controller.add(_state);
  }

  Future<void> update({
    TransmissionSpeed? speed,
    bool? wifiOnly,
    String? adminUserId,
    String? adminPassword,
  }) async {
    _state = _state.copyWith(
      speed: speed,
      wifiOnly: wifiOnly,
      adminUserId: adminUserId,
      adminPassword: adminPassword,
    );
    _controller.add(_state);
    await _persist();
  }

  Future<void> applyRemote(Map<String, dynamic> data) async {
    final speedName = data['speed']?.toString();
    final speed = TransmissionSpeed.values.firstWhere(
      (e) => e.name == speedName,
      orElse: () => _state.speed,
    );
    await update(
      speed: speed,
      wifiOnly: data['wifiOnly'] == true,
      adminUserId: data['adminUserId']?.toString(),
      adminPassword: data['adminPassword']?.toString(),
    );
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('policy.speed', _state.speed.name);
    await prefs.setBool('policy.wifiOnly', _state.wifiOnly);
    await prefs.setString('policy.adminUserId', _state.adminUserId);
    await prefs.setString('policy.adminPassword', _state.adminPassword);
  }
}
