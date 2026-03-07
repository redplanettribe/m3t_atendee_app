sealed class RegistrationFailure implements Exception {
  const RegistrationFailure();
}

/// Event code format is invalid (e.g. not 4 characters).
final class InvalidEventCode extends RegistrationFailure {
  const InvalidEventCode();
}

/// No event found for the given code.
final class EventNotFound extends RegistrationFailure {
  const EventNotFound();
}

/// Bad request (e.g. invalid payload).
final class RegistrationBadRequest extends RegistrationFailure {
  const RegistrationBadRequest();
}

/// Network or connectivity error.
final class RegistrationNetworkError extends RegistrationFailure {
  const RegistrationNetworkError();
}

/// Unspecified error.
final class RegistrationUnknownError extends RegistrationFailure {
  const RegistrationUnknownError();
}
