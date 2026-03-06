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

/// Thrown when fetching the current user's profile fails.
final class GetCurrentUserFailure implements Exception {
  GetCurrentUserFailure(this.message);

  final String message;

  @override
  String toString() => 'GetCurrentUserFailure($message)';
}

/// Thrown when updating the current user's profile fails.
final class UpdateCurrentUserFailure implements Exception {
  UpdateCurrentUserFailure(this.message);

  final String message;

  @override
  String toString() => 'UpdateCurrentUserFailure($message)';
}

/// Thrown when requesting a presigned avatar upload URL fails.
final class RequestAvatarUploadFailure implements Exception {
  RequestAvatarUploadFailure(this.message);

  final String message;

  @override
  String toString() => 'RequestAvatarUploadFailure($message)';
}

/// Thrown when uploading avatar bytes directly to the storage provider fails.
final class UploadAvatarFailure implements Exception {
  UploadAvatarFailure(this.message);

  final String message;

  @override
  String toString() => 'UploadAvatarFailure($message)';
}

/// Thrown when confirming the uploaded avatar with the backend fails.
final class ConfirmAvatarFailure implements Exception {
  ConfirmAvatarFailure(this.message);

  final String message;

  @override
  String toString() => 'ConfirmAvatarFailure($message)';
}

/// Thrown when registering for an event by code fails.
final class RegisterForEventByCodeFailure implements Exception {
  RegisterForEventByCodeFailure(
    this.message, {
    this.statusCode,
    this.errorCode,
  });

  final String message;
  final int? statusCode;
  final String? errorCode;

  @override
  String toString() => 'RegisterForEventByCodeFailure($message)';
}
