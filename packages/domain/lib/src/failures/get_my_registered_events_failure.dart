sealed class GetMyRegisteredEventsFailure implements Exception {}

/// Network or connectivity error when loading registered events.
final class GetMyRegisteredEventsNetworkError
    extends GetMyRegisteredEventsFailure {}

/// Unauthorized (e.g. token expired).
final class GetMyRegisteredEventsUnauthorized
    extends GetMyRegisteredEventsFailure {}

/// Unspecified error.
final class GetMyRegisteredEventsUnknown extends GetMyRegisteredEventsFailure {}
