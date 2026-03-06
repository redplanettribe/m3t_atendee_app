import 'package:domain/domain.dart';

/// Extension on [RegistrationFailure] for user-facing messages.
extension RegistrationFailureMessage on RegistrationFailure {
  String toDisplayMessage() => switch (this) {
        InvalidEventCode() =>
            'Please enter a valid 4-character event code.',
        EventNotFound() =>
            'No event found with this code. Check the code and try again.',
        RegistrationBadRequest() =>
            'Invalid request. Please check the event code.',
        RegistrationNetworkError() => 'Connection error. Please try again.',
        RegistrationUnknownError() => 'Something went wrong. Please try again.',
      };
}
