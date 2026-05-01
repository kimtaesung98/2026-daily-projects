part of 'vitals_bloc.dart';

enum VitalsStatusUI { initial, loading, loaded, failure }

/// VitalsBloc 의 단일 상태.
final class VitalsState extends Equatable {
  final VitalsStatusUI status;
  final List<VitalSample> samples;
  final List<AnomalyBand> anomalies;
  final Failure? failure;

  const VitalsState({
    this.status = VitalsStatusUI.initial,
    this.samples = const [],
    this.anomalies = const [],
    this.failure,
  });

  const VitalsState.initial() : this();

  VitalsState copyWith({
    VitalsStatusUI? status,
    List<VitalSample>? samples,
    List<AnomalyBand>? anomalies,
    Failure? failure,
    bool clearFailure = false,
  }) =>
      VitalsState(
        status: status ?? this.status,
        samples: samples ?? this.samples,
        anomalies: anomalies ?? this.anomalies,
        failure: clearFailure ? null : (failure ?? this.failure),
      );

  bool get isEmpty => samples.isEmpty;

  @override
  List<Object?> get props => [status, samples, anomalies, failure];
}
