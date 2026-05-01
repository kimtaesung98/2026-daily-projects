import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/senior.dart';
import '../../domain/entities/senior_status.dart';
import '../../domain/usecases/get_seniors.dart';
import '../../domain/usecases/watch_seniors.dart';

part 'senior_event.dart';
part 'senior_state.dart';

/// Senior 목록 / 실시간 모니터링 화면을 위한 BLoC.
@injectable
class SeniorBloc extends Bloc<SeniorEvent, SeniorState> {
  final GetSeniors _getSeniors;
  final WatchSeniors _watchSeniors;

  StreamSubscription<Either<Failure, List<Senior>>>? _subscription;

  SeniorBloc({
    required GetSeniors getSeniors,
    required WatchSeniors watchSeniors,
  })  : _getSeniors = getSeniors,
        _watchSeniors = watchSeniors,
        super(const SeniorState.initial()) {
    on<SeniorListRequested>(_onListRequested);
    on<SeniorListSubscribed>(_onListSubscribed);
    on<_SeniorListUpdated>(_onListUpdated);
  }

  Future<void> _onListRequested(
    SeniorListRequested event,
    Emitter<SeniorState> emit,
  ) async {
    emit(state.copyWith(status: SeniorStatusUI.loading, clearFailure: true));
    final result = await _getSeniors(
      GetSeniorsParams(guardianId: event.guardianId),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: SeniorStatusUI.failure,
        failure: failure,
      )),
      (seniors) => emit(state.copyWith(
        status: SeniorStatusUI.loaded,
        seniors: seniors,
        clearFailure: true,
      )),
    );
  }

  Future<void> _onListSubscribed(
    SeniorListSubscribed event,
    Emitter<SeniorState> emit,
  ) async {
    emit(state.copyWith(status: SeniorStatusUI.loading, clearFailure: true));
    await _subscription?.cancel();
    _subscription = _watchSeniors(
      WatchSeniorsParams(guardianId: event.guardianId),
    ).listen(
      (result) => add(_SeniorListUpdated(result)),
    );
  }

  void _onListUpdated(
    _SeniorListUpdated event,
    Emitter<SeniorState> emit,
  ) {
    event.result.fold(
      (failure) => emit(state.copyWith(
        status: SeniorStatusUI.failure,
        failure: failure,
      )),
      (seniors) => emit(state.copyWith(
        status: SeniorStatusUI.loaded,
        seniors: seniors,
        clearFailure: true,
      )),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
