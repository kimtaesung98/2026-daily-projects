import 'dart:developer' as developer;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../features/senior/domain/entities/senior.dart';

/// 긴급 상황(Emergency) 발생 시 호출되는 알림 서비스.
///
/// data 계층 [SeniorRepositoryImpl] 에서 RiskScore ≥ 80 감지 시 호출됩니다.
abstract class NotificationService {
  /// FCM 토큰 발급 / 권한 요청.
  Future<void> initialize();

  /// 긴급 알림을 발송한다.
  /// (현 단계에서는 로컬 푸시 / 디버그 로그로 동작; 추후 백엔드 연동 시 서버 호출로 교체)
  Future<void> notifyEmergency(Senior senior);
}

@LazySingleton(as: NotificationService)
class FirebaseNotificationService implements NotificationService {
  final FirebaseMessaging _messaging;

  const FirebaseNotificationService(this._messaging);

  @override
  Future<void> initialize() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final token = await _messaging.getToken();
    if (kDebugMode) {
      debugPrint('[NotificationService] FCM token: $token');
    }
  }

  @override
  Future<void> notifyEmergency(Senior senior) async {
    // TODO(team): 실제 배포 시 Cloud Functions / 백엔드 push 트리거로 교체.
    if (kDebugMode) {
      debugPrint(
        '[NotificationService] 🚨 EMERGENCY for '
        '${senior.name} (id=${senior.id}, score=${senior.riskScore.value})',
      );
    }
  }
}

/// Firebase 가 초기화되지 못한 환경(데모 모드 / 위젯 테스트 등) 에서 사용되는
/// no-op 구현. 콘솔 로그만 남깁니다.
class ConsoleNotificationService implements NotificationService {
  const ConsoleNotificationService();

  @override
  Future<void> initialize() async {
    developer.log(
      'demo mode: Firebase 미초기화 — push 권한 요청 건너뜀',
      name: 'CareConnect.Notification',
    );
  }

  @override
  Future<void> notifyEmergency(Senior senior) async {
    developer.log(
      '🚨 EMERGENCY (console-only) name=${senior.name} '
      'id=${senior.id} score=${senior.riskScore.value}',
      name: 'CareConnect.Notification',
    );
  }
}
