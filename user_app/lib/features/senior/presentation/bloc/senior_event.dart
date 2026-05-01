part of 'senior_bloc.dart';

/// SeniorBloc 이 처리하는 이벤트.
sealed class SeniorEvent extends Equatable {
  const SeniorEvent();

  @override
  List<Object?> get props => const [];
}

/// 보호자에게 등록된 시니어 목록을 1회 조회.
final class SeniorListRequested extends SeniorEvent {
  final String guardianId;
  const SeniorListRequested(this.guardianId);

  @override
  List<Object?> get props => [guardianId];
}

/// 보호자에게 등록된 시니어 목록을 실시간 구독 시작.
final class SeniorListSubscribed extends SeniorEvent {
  final String guardianId;
  const SeniorListSubscribed(this.guardianId);

  @override
  List<Object?> get props => [guardianId];
}

/// 내부 이벤트 — 스트림에서 새 데이터가 도착했을 때 발행.
final class _SeniorListUpdated extends SeniorEvent {
  final Either<Failure, List<Senior>> result;
  const _SeniorListUpdated(this.result);

  @override
  List<Object?> get props => [result];
}
