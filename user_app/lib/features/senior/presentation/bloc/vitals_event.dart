part of 'vitals_bloc.dart';

/// VitalsBloc 이벤트.
sealed class VitalsEvent extends Equatable {
  const VitalsEvent();

  @override
  List<Object?> get props => const [];
}

/// 시니어 한 명의 바이탈 스트림 구독 시작.
final class VitalsSubscribed extends VitalsEvent {
  final String seniorId;
  final Duration window;

  const VitalsSubscribed({
    required this.seniorId,
    this.window = const Duration(hours: 24),
  });

  @override
  List<Object?> get props => [seniorId, window];
}

/// 내부 이벤트 — Stream 으로부터 새 결과 수신.
final class _VitalsUpdated extends VitalsEvent {
  final Either<Failure, List<VitalSample>> result;
  const _VitalsUpdated(this.result);

  @override
  List<Object?> get props => [result];
}
