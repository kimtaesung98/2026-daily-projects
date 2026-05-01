import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/senior.dart';
import '../repositories/senior_repository.dart';

/// 보호자에게 등록된 시니어 목록을 실시간으로 구독한다.
///
/// Firestore snapshot stream 위에서 동작하며, RiskScore 가 변경되면
/// 즉시 새로운 [Senior] 리스트가 흘러 들어옵니다.
@injectable
class WatchSeniors implements StreamUseCase<List<Senior>, WatchSeniorsParams> {
  final SeniorRepository _repository;

  const WatchSeniors(this._repository);

  @override
  Stream<Either<Failure, List<Senior>>> call(WatchSeniorsParams params) =>
      _repository.watchSeniors(params.guardianId);
}

class WatchSeniorsParams extends Equatable {
  final String guardianId;
  const WatchSeniorsParams({required this.guardianId});

  @override
  List<Object?> get props => [guardianId];
}
