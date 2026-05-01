import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/senior.dart';
import '../repositories/senior_repository.dart';

/// 보호자(guardian) 한 명에게 등록된 시니어 전체 목록을 1회 조회한다.
@injectable
class GetSeniors implements UseCase<List<Senior>, GetSeniorsParams> {
  final SeniorRepository _repository;

  const GetSeniors(this._repository);

  @override
  Future<Either<Failure, List<Senior>>> call(GetSeniorsParams params) =>
      _repository.getSeniors(params.guardianId);
}

class GetSeniorsParams extends Equatable {
  final String guardianId;
  const GetSeniorsParams({required this.guardianId});

  @override
  List<Object?> get props => [guardianId];
}
