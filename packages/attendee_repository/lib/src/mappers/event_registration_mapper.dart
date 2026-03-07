import 'package:domain/domain.dart';
import 'package:m3t_api/m3t_api.dart';

/// Maps an [EventRegistration] API model to an [EventRegistrationEntity]
/// domain object.
///
/// Bridges the API layer (`m3t_api`) and the domain layer for registration
/// confirmation payloads returned after a successful event registration.
extension EventRegistrationMapper on EventRegistration {
  /// Converts this API model into an [EventRegistrationEntity].
  EventRegistrationEntity toDomain() => EventRegistrationEntity(
    id: id,
    eventId: eventId,
  );
}
