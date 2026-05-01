import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/app_mode.dart';
import 'di/injection.dart';
import 'services/notification_service.dart';

/// 앱 진입점.
///
/// 부트 시퀀스
/// 1. Flutter binding 초기화
/// 2. Firebase 초기화 시도
///    - 실패 시 Demo 모드로 폴백 (Mock DataSource / ConsoleNotificationService 등록)
/// 3. DI 컨테이너 구성 (`configureDependencies`)
/// 4. (Firebase 사용 가능할 때만) NotificationService 권한 요청
/// 5. App 위젯 실행
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── 1) Firebase 초기화 시도 ───────────────────────────────────────────
  // FlutterFire CLI 로 firebase_options.dart 가 생성되면 다음과 같이 사용:
  //   await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.currentPlatform,
  //   );
  bool firebaseAvailable = false;
  try {
    await Firebase.initializeApp();
    firebaseAvailable = true;
    developer.log('Firebase initialized', name: 'CareConnect.Boot');
  } catch (e, st) {
    developer.log(
      'Firebase init 실패 → Demo 모드로 폴백',
      name: 'CareConnect.Boot',
      error: e,
      stackTrace: st,
    );
  }

  // ─── 2) 글로벌 앱 모드 결정 ────────────────────────────────────────────
  AppMode.setDemoMode(!firebaseAvailable);

  // ─── 3) DI 컨테이너 구성 ───────────────────────────────────────────────
  await configureDependencies(useDemoMode: !firebaseAvailable);

  // ─── 4) Push 권한 요청 (실 Firebase 모드일 때만) ──────────────────────
  if (firebaseAvailable) {
    try {
      await sl<NotificationService>().initialize();
    } catch (e, st) {
      developer.log(
        'NotificationService 초기화 실패 (계속 진행)',
        name: 'CareConnect.Boot',
        error: e,
        stackTrace: st,
      );
    }
  }

  runApp(const App());
}
