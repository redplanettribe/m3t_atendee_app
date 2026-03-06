import 'package:domain/src/entities/event_registration.dart';
import 'package:domain/src/failures/registration_failure.dart';

/// Repository for attendee operations (e.g. registering for events).
abstract interface class AttendeeRepository {
  /// Registers the current user for the event identified by [eventCode]
  /// (4 characters). Idempotent: returns the same result if already registered.
  ///
  /// Throws [RegistrationFailure] on error.
  Future<EventRegistrationEntity> registerForEventByCode(String eventCode);
}
