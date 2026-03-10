// lib/providers/factory_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../data/repositories/machine_repository.dart';
import '../data/models/machine_model.dart';

class FactoryProvider extends ChangeNotifier {
  final MachineRepository _repository;
  FactoryProvider(this._repository);

  List<MachineModel> _machines = [];
  bool _isLoading = false;
  String? _errorMessage;

  Timer? _throttleTimer;
  bool _needsUpdate = false;

  List<MachineModel> get machines => _machines;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int _rawFetchCount = 0;    // 실제 데이터 수집 횟수
  int _uiUpdateCount = 0;    // 실제 UI 갱신(notify) 횟수
  String get flowReport => "수집: $_rawFetchCount | 갱신: $_uiUpdateCount (최적화율: ${((1 - _uiUpdateCount/_rawFetchCount) * 100).toStringAsFixed(1)}%)";
  
  // 데이터 수집 엔진 (실제로는 더 빈번하게 데이터가 들어온다고 가정)
  void startHighFrequencyMonitoring() {
    // 0.1초마다 데이터가 들어오는 극한 상황 시뮬레이션
    Stream.periodic(const Duration(milliseconds: 100)).listen((_) async {
      final newData = await _repository.getMachineStatuses();
      _machines = newData;
      
      // 데이터는 업데이트되었지만, 화면 갱신은 '쓰로틀러'에게 맡깁니다.
      _throttledNotify();
    });
  }
  
  // [안전 밸브] 0.5초에 최대 한 번만 화면을 새로 그리도록 제한
  void _throttledNotify() {
    _rawFetchCount++; // 데이터가 들어올 때마다 카운트
    if (_throttleTimer == null || !_throttleTimer!.isActive) {
      notifyListeners(); // 즉시 한 번 갱신

      _throttleTimer = Timer(const Duration(milliseconds: 500), () {
        if (_needsUpdate) {
          notifyListeners(); // 타이머 동안 쌓인 변경사항이 있다면 마지막으로 한 번 더 갱신
          _needsUpdate = false;
        }
      });
    } else {
      _needsUpdate = true; // 타이머가 작동 중일 때는 갱신 예약만 해둠
    }
  }
  int get rawFetchCount => _rawFetchCount;
  int get uiUpdateCount => _uiUpdateCount;

  String get optimizationRate {
    if (_rawFetchCount == 0) return "0";
    return ((1 - _uiUpdateCount / _rawFetchCount) * 100).toStringAsFixed(1);
  }
  
  @override
  void dispose() {
    _throttleTimer?.cancel();
    super.dispose();
  }
  
  // 데이터를 새로고침하는 함수
  Future<void> refreshData() async {
    _isLoading = true;
    _errorMessage = null; // 이전 에러 초기화
    notifyListeners();

    try {
      _machines = await _repository.getMachineStatuses();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}