import 'dart:developer' as developer;

import '../../../../core/error/exceptions.dart';
import '../models/senior_model.dart';
import '../models/vital_sample_model.dart';
import 'senior_remote_datasource.dart';

/// Firebase 가 초기화되지 못한 환경(데모 모드)에서 사용하는 in-memory 구현체.
///
/// - `seniors` 컬렉션 대용으로 4명의 샘플(정상/Idle/Warning/Emergency)을 즉시 반환.
/// - `vitals` 는 빈 리스트를 반환 → `SeniorRepositoryImpl` 의 기존 데모 폴백
///   (`DemoVitalsGenerator`) 가 자연스럽게 활용됩니다.
class MockSeniorRemoteDataSource implements SeniorRemoteDataSource {
  static const String _logName = 'CareConnect.DataSource.Mock';

  late final List<SeniorModel> _seniors;
  late final DateTime _now;

  MockSeniorRemoteDataSource() {
    _now = DateTime.now();
    _seniors = _seedSeniors();
    developer.log(
      'MockSeniorRemoteDataSource initialised with ${_seniors.length} senior(s)',
      name: _logName,
    );
  }

  List<SeniorModel> _seedSeniors() => [
        SeniorModel(
          id: 'demo-senior-001',
          name: '김복순',
          age: 78,
          guardianId: 'dev-guardian-001',
          riskScore: 12,
          lastActiveAt: _now.subtract(const Duration(minutes: 4)),
        ),
        SeniorModel(
          id: 'demo-senior-002',
          name: '박영자',
          age: 82,
          guardianId: 'dev-guardian-001',
          riskScore: 35,
          lastActiveAt: _now.subtract(const Duration(minutes: 38)),
        ),
        SeniorModel(
          id: 'demo-senior-003',
          name: '이순임',
          age: 75,
          guardianId: 'dev-guardian-001',
          riskScore: 64,
          lastActiveAt: _now.subtract(const Duration(minutes: 9)),
        ),
        SeniorModel(
          id: 'demo-senior-004',
          name: '최정수',
          age: 85,
          guardianId: 'dev-guardian-001',
          riskScore: 88,
          lastActiveAt: _now.subtract(const Duration(minutes: 22)),
        ),
      ];

  // ─── seniors ───────────────────────────────────────────────────────────

  @override
  Future<List<SeniorModel>> getSeniors(String guardianId) async {
    developer.log('getSeniors(guardianId=$guardianId)', name: _logName);
    return _seniors.where((s) => s.guardianId == guardianId).toList();
  }

  @override
  Future<SeniorModel> getSeniorById(String seniorId) async {
    developer.log('getSeniorById(seniorId=$seniorId)', name: _logName);
    final found = _seniors.where((s) => s.id == seniorId).toList();
    if (found.isEmpty) {
      throw ServerException('Senior not found: $seniorId');
    }
    return found.first;
  }

  @override
  Stream<List<SeniorModel>> watchSeniors(String guardianId) async* {
    developer.log('watchSeniors(guardianId=$guardianId)', name: _logName);
    yield _seniors.where((s) => s.guardianId == guardianId).toList();
  }

  @override
  Stream<SeniorModel> watchSeniorById(String seniorId) async* {
    developer.log('watchSeniorById(seniorId=$seniorId)', name: _logName);
    final found = _seniors.where((s) => s.id == seniorId).toList();
    if (found.isEmpty) {
      throw ServerException('Senior not found: $seniorId');
    }
    yield found.first;
  }

  // ─── vitals ───────────────────────────────────────────────────────────

  /// 일부러 빈 리스트를 반환 → Repository 가 [DemoVitalsGenerator] 폴백을 사용해
  /// 24시간 합성 시계열을 발행하도록 둔다.
  @override
  Stream<List<VitalSampleModel>> watchVitals(
    String seniorId, {
    required DateTime since,
  }) async* {
    developer.log(
      'watchVitals(seniorId=$seniorId, since=$since) — returning empty so '
      'Repository fallback (DemoVitalsGenerator) will fire',
      name: _logName,
    );
    yield const <VitalSampleModel>[];
  }
}
