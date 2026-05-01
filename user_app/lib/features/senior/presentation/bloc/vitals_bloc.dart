import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/anomaly_detector.dart';
import '../../domain/entities/anomaly_band.dart';
import '../../domain/entities/vital_sample.dart';
import '../../domain/usecases/watch_senior_vitals.dart';

part 'vitals_event.dart';
part 'vitals_state.dart';

/// 시니어 상세 화면 — 24시간 바이탈 시계열 + 이상 구간 산출 BLoC.
@injectable
class VitalsBloc extends Bloc<VitalsEvent, VitalsState> {
  final WatchSeniorVitals _watchVitals;
  final AnomalyDetector _detector;

  StreamSubscription<Either<Failure, List<VitalSample>>>? _subscription;

  VitalsBloc({
    required WatchSeniorVitals watchVitals,
    AnomalyDetector detector = const AnomalyDetector(),
  })  : _watchVitals = watchVitals,
        _detector = detector,
        super(const VitalsState.initial()) {
    on<VitalsSubscribed>(_onSubscribed);
    on<_VitalsUpdated>(_onUpdated);
  }

  Future<void> _onSubscribed(
    VitalsSubscribed event,
    Emitter<VitalsState> emit,
  ) async {
    developer.log(
      'VitalsSubscribed(seniorId=${event.seniorId})',
      name: 'CareConnect.Bloc.Vitals',
    );
    emit(state.copyWith(status: VitalsStatusUI.loading, clearFailure: true));
    await _subscription?.cancel();
    _subscription = _watchVitals(
      WatchSeniorVitalsParams(
        seniorId: event.seniorId,
        window: event.window,
      ),
    ).listen(
      (result) => add(_VitalsUpdated(result)),
      onError: (Object e, StackTrace st) {
        developer.log(
          'subscription error',
          name: 'CareConnect.Bloc.Vitals',
          error: e,
          stackTrace: st,
        );
      },
    );
  }

  void _onUpdated(_VitalsUpdated event, Emitter<VitalsState> emit) {
    event.result.fold(
      (failure) {
        developer.log(
          'state ← failure: ${failure.message}',
          name: 'CareConnect.Bloc.Vitals',
        );
        emit(state.copyWith(
          status: VitalsStatusUI.failure,
          failure: failure,
        ));
      },
      (samples) {
        final bands = _detector.detect(samples);
        developer.log(
          'state ← loaded(${samples.length} samples, ${bands.length} anomaly bands)',
          name: 'CareConnect.Bloc.Vitals',
        );
        emit(state.copyWith(
          status: VitalsStatusUI.loaded,
          samples: samples,
          anomalies: bands,
          clearFailure: true,
        ));
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
