part of 'senior_bloc.dart';

enum SeniorStatusUI { initial, loading, loaded, failure }

/// SeniorBloc 의 단일 상태.
final class SeniorState extends Equatable {
  final SeniorStatusUI status;
  final List<Senior> seniors;
  final Failure? failure;

  const SeniorState({
    this.status = SeniorStatusUI.initial,
    this.seniors = const [],
    this.failure,
  });

  /// 초기 상태.
  const SeniorState.initial() : this();

  SeniorState copyWith({
    SeniorStatusUI? status,
    List<Senior>? seniors,
    Failure? failure,
    bool clearFailure = false,
  }) =>
      SeniorState(
        status: status ?? this.status,
        seniors: seniors ?? this.seniors,
        failure: clearFailure ? null : (failure ?? this.failure),
      );

  /// 긴급(Emergency) 상태인 시니어가 한 명이라도 있는지.
  bool get hasEmergency =>
      seniors.any((s) => s.status == SeniorStatus.emergency);

  @override
  List<Object?> get props => [status, seniors, failure];
}
