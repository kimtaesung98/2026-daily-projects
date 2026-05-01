import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// 모든 UseCase 의 공통 시그니처.
///
/// - [T] : 성공 시 반환 타입
/// - [Params] : 호출 시 전달되는 파라미터 (없으면 [NoParams] 사용)
///
/// 예)
/// ```dart
/// class GetSeniors implements UseCase<List<Senior>, NoParams> {
///   final SeniorRepository repository;
///   GetSeniors(this.repository);
///
///   @override
///   Future<Either<Failure, List<Senior>>> call(NoParams params) =>
///       repository.getSeniors();
/// }
/// ```
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Stream 을 반환하는 UseCase.
/// (Firestore 실시간 구독 등 반응형 데이터 흐름 시 사용)
abstract class StreamUseCase<T, Params> {
  Stream<Either<Failure, T>> call(Params params);
}

/// 파라미터가 없는 UseCase 호출 시 사용.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => const [];
}
