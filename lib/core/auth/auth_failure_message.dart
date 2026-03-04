import 'package:domain/domain.dart';

/// Extension on [AuthFailure] that maps each failure variant to a
/// human-readable display message.
///
/// Lives in the presentation layer intentionally. When l10n is introduced,
/// accept `AppLocalizations` as a parameter and return localised strings
/// from the arb file instead.
extension AuthFailureMessage on AuthFailure {
  String toDisplayMessage() => switch (this) {
    NetworkError() => 'A network error occurred. Please try again.',
    InvalidCode() => 'The verification code is invalid.',
    InvalidEmail() => 'The email address is invalid.',
    UnknownError() => 'An unexpected error occurred. Please try again.',
  };
}
