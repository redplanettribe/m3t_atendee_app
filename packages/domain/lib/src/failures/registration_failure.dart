sealed class RegistrationFailure implements Exception {}

/// Event code format is invalid (e.g. not 4 characters).
final class InvalidEventCode extends RegistrationFailure {}

/// No event found for the given code.
final class EventNotFound extends RegistrationFailure {}

/// Bad request (e.g. invalid payload).
final class RegistrationBadRequest extends RegistrationFailure {}

/// Network or connectivity error.
final class RegistrationNetworkError extends RegistrationFailure {}

/// Unspecified error.
final class RegistrationUnknownError extends RegistrationFailure {}
