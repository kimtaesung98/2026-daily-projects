import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/senior.dart';
import '../entities/vital_sample.dart';

/// Senior 도메인이 의존하는 추상 Repository.
///
/// data 계층(`SeniorRepositoryImpl`) 이 Firestore / Mock 등 구체 구현을 담당합니다.
/// 도메인 계층은 이 인터페이스에만 의존합니다.
abstract class SeniorRepository {
  /// 보호자가 등록한 시니어 전체 목록을 1회 조회.
  Future<Either<Failure, List<Senior>>> getSeniors(String guardianId);

  /// 단일 시니어 상세 조회.
  Future<Either<Failure, Senior>> getSeniorById(String seniorId);

  /// 보호자가 등록한 시니어 목록을 실시간 구독.
  /// Firestore snapshot 기반으로 RiskScore 변경을 즉시 반영합니다.
  Stream<Either<Failure, List<Senior>>> watchSeniors(String guardianId);

  /// 단일 시니어 실시간 구독.
  Stream<Either<Failure, Senior>> watchSeniorById(String seniorId);

  /// 시니어의 바이탈(Risk/HR/활동량/수면) 시계열을 [window] 기간만큼 실시간 구독.
  ///
  /// Firestore 서브컬렉션 `seniors/{seniorId}/vitals` 에서
  /// `recordedAt >= now - window` 인 도큐먼트를 시간 오름차순으로 흘려보냅니다.
  Stream<Either<Failure, List<VitalSample>>> watchVitals(
    String seniorId, {
    Duration window,
  });
}
