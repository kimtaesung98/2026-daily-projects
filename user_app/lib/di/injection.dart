import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../features/senior/data/datasources/mock_senior_remote_datasource.dart';
import '../features/senior/data/datasources/senior_remote_datasource.dart';
import '../features/senior/data/repositories/senior_repository_impl.dart';
import '../features/senior/domain/repositories/senior_repository.dart';
import '../features/senior/domain/usecases/get_seniors.dart';
import '../features/senior/domain/usecases/watch_senior_vitals.dart';
import '../features/senior/domain/usecases/watch_seniors.dart';
import '../features/senior/presentation/bloc/senior_bloc.dart';
import '../features/senior/presentation/bloc/vitals_bloc.dart';
import '../services/notification_service.dart';

// ──────────────────────────────────────────────────────────────────────────
//  injectable 사용 시:
//    1. `dart run build_runner build --delete-conflicting-outputs`
//    2. 아래 import / @InjectableInit 활성화
//    3. main.dart 에서 `await configureDependencies();` 호출
//
//  현재는 build_runner 미실행 환경에서도 즉시 실행되도록
//  수동 등록(`configureDependenciesManually`) 을 함께 제공합니다.
// ──────────────────────────────────────────────────────────────────────────

// import 'injection.config.dart';

/// Service Locator 단일 인스턴스.
final GetIt sl = GetIt.instance;

/// build_runner 실행 후 사용할 자동 DI 초기화.
///
/// ```bash
/// dart run build_runner build --delete-conflicting-outputs
/// ```
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureDependencies({bool useDemoMode = false}) async {
  // build_runner 가 한 번이라도 실행되어 injection.config.dart 가 생성된 뒤에는
  // 아래 라인을 활성화하고 수동 등록 함수를 제거하세요.
  //
  // await init(sl, environment: useDemoMode ? Environment.dev : Environment.prod);

  await configureDependenciesManually(useDemoMode: useDemoMode);
}

/// build_runner 미실행 환경에서도 동작하는 수동 DI 등록.
///
/// [useDemoMode] 가 true 면 Firebase 인스턴스 등록을 건너뛰고
/// Mock DataSource / ConsoleNotificationService 를 사용한다.
Future<void> configureDependenciesManually({bool useDemoMode = false}) async {
  // ─── External (Firebase) — demo 모드에서는 등록하지 않는다 ─────────────
  if (!useDemoMode) {
    sl.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );
    sl.registerLazySingleton<FirebaseMessaging>(
      () => FirebaseMessaging.instance,
    );
  }

  // ─── Services ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<NotificationService>(
    () => useDemoMode
        ? const ConsoleNotificationService()
        : FirebaseNotificationService(sl()),
  );

  // ─── DataSources ───────────────────────────────────────────────────────
  sl.registerLazySingleton<SeniorRemoteDataSource>(
    () => useDemoMode
        ? MockSeniorRemoteDataSource()
        : SeniorRemoteDataSourceImpl(sl()),
  );

  // ─── Repositories ──────────────────────────────────────────────────────
  sl.registerLazySingleton<SeniorRepository>(
    () => SeniorRepositoryImpl(remote: sl(), notifications: sl()),
  );

  // ─── UseCases ──────────────────────────────────────────────────────────
  sl.registerFactory<GetSeniors>(() => GetSeniors(sl()));
  sl.registerFactory<WatchSeniors>(() => WatchSeniors(sl()));
  sl.registerFactory<WatchSeniorVitals>(() => WatchSeniorVitals(sl()));

  // ─── Blocs (factory: 화면 진입마다 새 인스턴스) ───────────────────────
  sl.registerFactory<SeniorBloc>(
    () => SeniorBloc(getSeniors: sl(), watchSeniors: sl()),
  );
  sl.registerFactory<VitalsBloc>(
    () => VitalsBloc(watchVitals: sl()),
  );
}

// 환경 모드 — 통합 테스트 / 위젯 테스트에서 mock 으로 교체할 때 사용.
//
// `@Environment(Environment.dev)` 처럼 클래스/메서드 단위로 직접 붙여 사용합니다.
// 예) `@dev @LazySingleton(as: SeniorRepository) class FakeSeniorRepository ...`
//
// const dev = Environment.dev;
// const prod = Environment.prod;
