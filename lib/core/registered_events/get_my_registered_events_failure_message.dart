import 'package:domain/domain.dart';

/// Extension on [GetMyRegisteredEventsFailure] for user-facing messages.
extension GetMyRegisteredEventsFailureMessage on GetMyRegisteredEventsFailure {
  String toDisplayMessage() => switch (this) {
        GetMyRegisteredEventsNetworkError() =>
          'Connection error. Please try again.',
        GetMyRegisteredEventsUnauthorized() => 'Please sign in again.',
        GetMyRegisteredEventsUnknown() =>
          'Something went wrong. Please try again.',
      };
}
