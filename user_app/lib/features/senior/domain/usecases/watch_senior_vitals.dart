import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/vital_sample.dart';
import '../repositories/senior_repository.dart';

/// 시니어 한 명의 바이탈 시계열을 [window] (기본 24시간) 만큼 실시간 구독한다.
@injectable
class WatchSeniorVitals
    implements StreamUseCase<List<VitalSample>, WatchSeniorVitalsParams> {
  final SeniorRepository _repository;

  const WatchSeniorVitals(this._repository);

  @override
  Stream<Either<Failure, List<VitalSample>>> call(
    WatchSeniorVitalsParams params,
  ) {
    developer.log(
      'call(seniorId=${params.seniorId}, window=${params.window})',
      name: 'CareConnect.UseCase.WatchSeniorVitals',
    );
    return _repository.watchVitals(
      params.seniorId,
      window: params.window,
    );
  }
}

class WatchSeniorVitalsParams extends Equatable {
  final String seniorId;
  final Duration window;

  const WatchSeniorVitalsParams({
    required this.seniorId,
    this.window = const Duration(hours: 24),
  });

  @override
  List<Object?> get props => [seniorId, window];
}
