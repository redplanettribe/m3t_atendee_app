/// Thrown when a login-code request fails.
final class RequestLoginCodeFailure implements Exception {
  RequestLoginCodeFailure(this.message);

  final String message;

  @override
  String toString() => 'RequestLoginCodeFailure($message)';
}

/// Thrown when a login-code verification request fails.
final class VerifyLoginCodeFailure implements Exception {
  VerifyLoginCodeFailure(this.message);

  final String message;

  @override
  String toString() => 'VerifyLoginCodeFailure($message)';
}
