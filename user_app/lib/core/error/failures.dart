import 'package:equatable/equatable.dart';

/// 도메인/데이터 계층에서 사용하는 모든 실패(Failure)의 부모 타입.
///
/// 모든 Repository · UseCase 는 `Either<Failure, T>` 를 반환하여
/// 호출 측이 [Failure] 의 타입을 분기 처리하도록 강제합니다.
sealed class Failure extends Equatable {
  /// 사용자에게 노출 가능한 메시지 (UI 노출용 - i18n key 등)
  final String message;

  /// 디버그/로깅용 상세 정보
  final Object? cause;

  const Failure(this.message, {this.cause});

  @override
  List<Object?> get props => [message, cause];
}

/// 서버/Firestore 통신 실패 (HTTP, gRPC, FirebaseException 등)
final class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.cause});
}

/// 인증 실패 (토큰 만료, 권한 부족 등)
final class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.cause});
}

/// 네트워크 미연결 실패
final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'No internet connection',
    Object? cause,
  ]) : super(cause: cause);
}

/// 로컬 캐시/디스크 실패
final class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.cause});
}

/// 입력값 검증 실패 (RiskScore 범위 초과 등)
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.cause});
}

/// 어떤 케이스에도 해당하지 않는 알 수 없는 실패
final class UnknownFailure extends Failure {
  const UnknownFailure([
    super.message = 'Unknown error',
    Object? cause,
  ]) : super(cause: cause);
}
