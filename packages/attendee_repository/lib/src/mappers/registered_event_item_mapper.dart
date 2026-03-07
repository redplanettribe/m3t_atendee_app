import 'package:domain/domain.dart';
import 'package:m3t_api/m3t_api.dart';

/// Maps a [ListMyRegisteredEventsItem] API response to a
/// [RegisteredEventEntity] domain object.
///
/// Bridges the API layer (`m3t_api`) and the domain layer, isolating all
/// field-name and type-conversion concerns from the rest of the repository.
extension RegisteredEventItemMapper on ListMyRegisteredEventsItem {
  /// Converts this API item into a [RegisteredEventEntity].
  ///
  /// Throws a [FormatException] if `start_date` is absent or cannot be parsed
  /// as an ISO 8601 date — see [_parseStartDate].
  RegisteredEventEntity toDomain() => RegisteredEventEntity(
    eventId: event.id,
    name: event.name,
    registrationId: registration.id,
    startDate: _parseStartDate(event.startDate, event.id),
    description: event.description,
    eventCode: event.eventCode,
    durationDays: event.durationDays,
    thumbnailUrl: event.thumbnailUrl,
  );
}

/// Parses [raw] as an ISO 8601 date, throwing [FormatException] loudly on any
/// contract violation (null or malformed value).
///
/// A `startDate` that is missing or unparseable is a server contract violation
/// — it must never be silently swallowed or null-propagated into timeline
/// classification.
DateTime _parseStartDate(String? raw, String eventId) {
  if (raw == null) {
    throw FormatException(
      'Event "$eventId" is missing required field start_date.',
    );
  }
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) {
    throw FormatException(
      'Event "$eventId" has invalid start_date value: "$raw".',
    );
  }
  return parsed;
}
