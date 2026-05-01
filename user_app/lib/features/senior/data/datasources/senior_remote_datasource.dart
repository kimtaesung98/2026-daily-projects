import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../models/senior_model.dart';
import '../models/vital_sample_model.dart';

/// Firestore 와 통신하는 원격 데이터 소스 추상화.
///
/// Repository 는 이 인터페이스에만 의존하므로, 테스트 시 Mock 으로 손쉽게 교체 가능합니다.
abstract class SeniorRemoteDataSource {
  Future<List<SeniorModel>> getSeniors(String guardianId);
  Future<SeniorModel> getSeniorById(String seniorId);

  Stream<List<SeniorModel>> watchSeniors(String guardianId);
  Stream<SeniorModel> watchSeniorById(String seniorId);

  /// `seniors/{seniorId}/vitals` 서브컬렉션을 [since] 이후로 시간 오름차순 구독.
  Stream<List<VitalSampleModel>> watchVitals(
    String seniorId, {
    required DateTime since,
  });
}

@LazySingleton(as: SeniorRemoteDataSource)
class SeniorRemoteDataSourceImpl implements SeniorRemoteDataSource {
  static const String _collection = 'seniors';

  final FirebaseFirestore _firestore;

  const SeniorRemoteDataSourceImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _seniors =>
      _firestore.collection(_collection);

  @override
  Future<List<SeniorModel>> getSeniors(String guardianId) async {
    developer.log(
      'getSeniors(guardianId=$guardianId)',
      name: 'CareConnect.DataSource',
    );
    try {
      final snapshot = await _seniors
          .where('guardianId', isEqualTo: guardianId)
          .get();
      final models = snapshot.docs.map(SeniorModel.fromFirestore).toList();
      developer.log(
        'getSeniors → ${models.length} doc(s)',
        name: 'CareConnect.DataSource',
      );
      return models;
    } on FirebaseException catch (e, st) {
      throw ServerException(e.message ?? e.code, cause: st);
    }
  }

  @override
  Future<SeniorModel> getSeniorById(String seniorId) async {
    developer.log(
      'getSeniorById(seniorId=$seniorId)',
      name: 'CareConnect.DataSource',
    );
    try {
      final doc = await _seniors.doc(seniorId).get();
      if (!doc.exists) {
        throw ServerException('Senior not found: $seniorId');
      }
      return SeniorModel.fromFirestore(doc);
    } on FirebaseException catch (e, st) {
      throw ServerException(e.message ?? e.code, cause: st);
    }
  }

  @override
  Stream<List<SeniorModel>> watchSeniors(String guardianId) {
    developer.log(
      'watchSeniors(guardianId=$guardianId)',
      name: 'CareConnect.DataSource',
    );
    return _seniors
        .where('guardianId', isEqualTo: guardianId)
        .snapshots()
        .map((snapshot) {
      final models = snapshot.docs.map(SeniorModel.fromFirestore).toList();
      developer.log(
        'seniors snapshot emitted: ${models.length} doc(s)',
        name: 'CareConnect.DataSource',
      );
      return models;
    });
  }

  @override
  Stream<SeniorModel> watchSeniorById(String seniorId) {
    developer.log(
      'watchSeniorById(seniorId=$seniorId)',
      name: 'CareConnect.DataSource',
    );
    return _seniors.doc(seniorId).snapshots().map((doc) {
      if (!doc.exists) {
        throw ServerException('Senior not found: $seniorId');
      }
      return SeniorModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<VitalSampleModel>> watchVitals(
    String seniorId, {
    required DateTime since,
  }) {
    developer.log(
      'watchVitals(seniorId=$seniorId, since=$since)',
      name: 'CareConnect.DataSource',
    );
    return _seniors
        .doc(seniorId)
        .collection('vitals')
        .where('recordedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .orderBy('recordedAt')
        .snapshots()
        .map((snapshot) {
      final models =
          snapshot.docs.map(VitalSampleModel.fromFirestore).toList();
      developer.log(
        'vitals snapshot emitted: ${models.length} doc(s)',
        name: 'CareConnect.DataSource',
      );
      return models;
    });
  }
}
