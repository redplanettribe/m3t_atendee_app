import 'package:domain/src/entities/event_registration.dart';
import 'package:domain/src/entities/registered_event.dart';
import 'package:domain/src/failures/get_my_registered_events_failure.dart';
import 'package:domain/src/failures/registration_failure.dart';

/// Repository for attendee operations (e.g. registering for events).
abstract interface class AttendeeRepository {
  /// Registers the current user for the event identified by [eventCode]
  /// (4 characters). Idempotent: returns the same result if already registered.
  ///
  /// Throws [RegistrationFailure] on error.
  Future<EventRegistrationEntity> registerForEventByCode(String eventCode);

  /// Returns the list of events the current user is registered for.
  /// Optional [status]: active, past, or all (default all).
  /// Optional [page] and [pageSize] for pagination.
  ///
  /// Throws [GetMyRegisteredEventsFailure] on error.
  Future<List<RegisteredEventEntity>> getMyRegisteredEvents({
    String? status,
    int? page,
    int? pageSize,
  });

  /// Returns the last cached list synchronously.
  /// Returns an empty list if no cache exists. Never throws.
  List<RegisteredEventEntity> getCachedRegisteredEvents();

  /// Clears local cache.
  Future<void> clearCache();
}
