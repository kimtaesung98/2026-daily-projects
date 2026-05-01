/// 데이터 계층(DataSource) 에서 throw 하는 예외들.
/// Repository 단계에서 [Failure] 로 변환되어 도메인으로 전달됩니다.
class ServerException implements Exception {
  final String message;
  final Object? cause;
  const ServerException(this.message, {this.cause});

  @override
  String toString() => 'ServerException: $message';
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection']);

  @override
  String toString() => 'NetworkException: $message';
}
