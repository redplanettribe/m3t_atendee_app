sealed class AuthFailure implements Exception {}

final class InvalidEmail extends AuthFailure {}

final class InvalidCode extends AuthFailure {}

final class NetworkError extends AuthFailure {}

final class UnknownError extends AuthFailure {}
