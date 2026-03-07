import 'package:domain/src/entities/registered_event.dart';
import 'package:domain/src/timeline/event_timeline_bucket.dart';
import 'package:domain/src/timeline/registered_events_timeline.dart';

/// Pure classifier that groups registered events into temporal buckets.
///
/// All date comparisons use calendar-date semantics (time-of-day is stripped).
/// Accepts a `referenceDate` so callers control the "now" boundary, enabling
/// deterministic testing without mocking clocks.
///
/// Duration normalization: `null` or non-positive `durationDays` defaults to 1.
abstract final class RegisteredEventsTimelineClassifier {
  /// Classifies [events] into a [RegisteredEventsTimeline] relative to
  /// the calendar date of [referenceDate].
  static RegisteredEventsTimeline classify(
    List<RegisteredEventEntity> events, {
    required DateTime referenceDate,
  }) {
    if (events.isEmpty) return .empty;

    final today = _dayOnly(referenceDate);

    final currentBucket = <RegisteredEventEntity>[];
    final upcomingBucket = <RegisteredEventEntity>[];
    final pastBucket = <RegisteredEventEntity>[];

    for (final event in events) {
      switch (_classifyEvent(event, today)) {
        case .current:
          currentBucket.add(event);
        case .upcoming:
          upcomingBucket.add(event);
        case .past:
          pastBucket.add(event);
      }
    }

    currentBucket.sort(_compareCurrentEvents);
    upcomingBucket.sort(_compareUpcomingEvents);
    pastBucket.sort(_comparePastEvents);

    return RegisteredEventsTimeline(
      current: List.unmodifiable(currentBucket),
      upcoming: List.unmodifiable(upcomingBucket),
      past: List.unmodifiable(pastBucket),
    );
  }

  // ---------------------------------------------------------------------------
  // Classification
  // ---------------------------------------------------------------------------

  static EventTimelineBucket _classifyEvent(
    RegisteredEventEntity event,
    DateTime today,
  ) {
    final startDay = _dayOnly(event.startDate);
    final endExclusive = startDay.add(
      Duration(days: _effectiveDuration(event.durationDays)),
    );

    if (today.isBefore(startDay)) return .upcoming;
    if (today.isBefore(endExclusive)) return .current;
    return .past;
  }

  // ---------------------------------------------------------------------------
  // Sorting
  // ---------------------------------------------------------------------------

  /// Current events: soonest ending -> earliest start -> name.
  static int _compareCurrentEvents(
    RegisteredEventEntity left,
    RegisteredEventEntity right,
  ) {
    final byEnd = _endExclusive(left).compareTo(_endExclusive(right));
    if (byEnd != 0) return byEnd;

    final byStart = left.startDate.compareTo(right.startDate);
    if (byStart != 0) return byStart;

    return left.name.compareTo(right.name);
  }

  /// Upcoming events: soonest starting -> name.
  static int _compareUpcomingEvents(
    RegisteredEventEntity left,
    RegisteredEventEntity right,
  ) {
    final byStart = left.startDate.compareTo(right.startDate);
    if (byStart != 0) return byStart;

    return left.name.compareTo(right.name);
  }

  /// Past events: most recently ended -> name.
  static int _comparePastEvents(
    RegisteredEventEntity left,
    RegisteredEventEntity right,
  ) {
    // Reverse order — most recent first.
    final byStart = right.startDate.compareTo(left.startDate);
    if (byStart != 0) return byStart;

    return left.name.compareTo(right.name);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static DateTime _endExclusive(RegisteredEventEntity event) {
    final startDay = _dayOnly(event.startDate);
    return startDay.add(
      Duration(days: _effectiveDuration(event.durationDays)),
    );
  }

  /// Normalizes duration: `null` or non-positive -> 1.
  static int _effectiveDuration(int? durationDays) =>
      (durationDays != null && durationDays > 0) ? durationDays : 1;

  /// Strips time-of-day, producing a midnight-local date.
  static DateTime _dayOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
