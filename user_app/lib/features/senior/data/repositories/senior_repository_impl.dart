import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../services/notification_service.dart';
import '../../domain/entities/senior.dart';
import '../../domain/entities/senior_status.dart';
import '../../domain/entities/vital_sample.dart';
import '../../domain/repositories/senior_repository.dart';
import '../datasources/demo_vitals_generator.dart';
import '../datasources/senior_remote_datasource.dart';

/// 도메인 [SeniorRepository] 의 구체 구현.
///
/// - Firestore [SeniorRemoteDataSource] 를 호출하고
/// - 예외를 [Failure] 로 변환하며
/// - RiskScore ≥ 80 (Emergency) 시 [NotificationService] 를 호출합니다.
@LazySingleton(as: SeniorRepository)
class SeniorRepositoryImpl implements SeniorRepository {
  final SeniorRemoteDataSource _remote;
  final NotificationService _notifications;
  final DemoVitalsGenerator _demo;

  /// 직전에 알림을 보낸 시니어 ID 캐시 — 같은 Emergency 가 연속 알림되지 않도록 디바운스.
  final Set<String> _alreadyNotified = <String>{};

  SeniorRepositoryImpl({
    required SeniorRemoteDataSource remote,
    required NotificationService notifications,
    DemoVitalsGenerator demoVitals = const DemoVitalsGenerator(),
  })  : _remote = remote,
        _notifications = notifications,
        _demo = demoVitals;

  // ─── 1회 조회 ────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Senior>>> getSeniors(String guardianId) async {
    try {
      final models = await _remote.getSeniors(guardianId);
      final entities = models.map((m) => m.toEntity()).toList();
      _checkAndNotify(entities);
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, cause: e.cause));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString(), e));
    }
  }

  @override
  Future<Either<Failure, Senior>> getSeniorById(String seniorId) async {
    try {
      final senior = (await _remote.getSeniorById(seniorId)).toEntity();
      _checkAndNotify([senior]);
      return Right(senior);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, cause: e.cause));
    } catch (e) {
      return Left(UnknownFailure(e.toString(), e));
    }
  }

  // ─── 실시간 구독 ────────────────────────────────────────────────────────

  @override
  Stream<Either<Failure, List<Senior>>> watchSeniors(String guardianId) {
    return _remote.watchSeniors(guardianId).map<Either<Failure, List<Senior>>>(
      (models) {
        final entities = models.map((m) => m.toEntity()).toList();
        _checkAndNotify(entities);
        return Right(entities);
      },
    ).handleError(
      (Object error) => Left<Failure, List<Senior>>(_mapError(error)),
    );
  }

  @override
  Stream<Either<Failure, Senior>> watchSeniorById(String seniorId) {
    return _remote.watchSeniorById(seniorId).map<Either<Failure, Senior>>(
      (model) {
        final senior = model.toEntity();
        _checkAndNotify([senior]);
        return Right(senior);
      },
    ).handleError(
      (Object error) => Left<Failure, Senior>(_mapError(error)),
    );
  }

  @override
  Stream<Either<Failure, List<VitalSample>>> watchVitals(
    String seniorId, {
    Duration window = const Duration(hours: 24),
  }) {
    final since = DateTime.now().subtract(window);
    developer.log(
      'watchVitals(seniorId=$seniorId, window=$window) → since=$since',
      name: 'CareConnect.Repository',
    );
    return _remote
        .watchVitals(seniorId, since: since)
        .map<Either<Failure, List<VitalSample>>>((models) {
      final entities = models.map((m) => m.toEntity()).toList();
      // 데이터가 없으면 데모 시계열로 폴백 (개발/시연 편의)
      if (entities.isEmpty) {
        final demo = _demo.generate24h();
        developer.log(
          'no vitals in Firestore — falling back to ${demo.length} demo sample(s)',
          name: 'CareConnect.Repository',
        );
        return Right(demo);
      }
      developer.log(
        'mapped ${entities.length} VitalSampleModel → VitalSample',
        name: 'CareConnect.Repository',
      );
      return Right(entities);
    }).handleError((Object error, StackTrace st) {
      developer.log(
        'watchVitals error',
        name: 'CareConnect.Repository',
        error: error,
        stackTrace: st,
      );
      return Left<Failure, List<VitalSample>>(_mapError(error));
    });
  }

  // ─── helpers ────────────────────────────────────────────────────────────

  Failure _mapError(Object error) {
    if (error is ServerException) {
      return ServerFailure(error.message, cause: error.cause);
    }
    if (error is FirebaseException) {
      return ServerFailure(error.message ?? error.code);
    }
    return UnknownFailure(error.toString(), error);
  }

  /// RiskScore 80 이상(=Emergency) 시 알림 서비스 호출.
  /// 같은 시니어에 대한 중복 알림은 방지합니다.
  void _checkAndNotify(List<Senior> seniors) {
    for (final s in seniors) {
      if (s.status == SeniorStatus.emergency) {
        if (_alreadyNotified.add(s.id)) {
          _notifications.notifyEmergency(s);
        }
      } else {
        // 상태가 회복되면 디바운스 캐시에서 제거 → 다음 emergency 시 다시 알림
        _alreadyNotified.remove(s.id);
      }
    }
  }
}
