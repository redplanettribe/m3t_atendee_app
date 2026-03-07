import 'package:domain/src/entities/registered_event.dart';
import 'package:equatable/equatable.dart';

/// Precomputed, immutable temporal snapshot of registered events.
///
/// Each bucket is pre-sorted by its natural ordering:
/// - [current]: soonest ending first, then by start date, then by name.
/// - [upcoming]: soonest starting first, then by name.
/// - [past]: most recently ended first, then by name.
///
/// Produced by `RegisteredEventsTimelineClassifier`. Do not construct
/// manually outside of tests.
final class RegisteredEventsTimeline extends Equatable {
  const RegisteredEventsTimeline({
    this.current = const [],
    this.upcoming = const [],
    this.past = const [],
  });

  /// Canonical empty instance for initial/cleared state.
  static const empty = RegisteredEventsTimeline();

  /// Events whose date range includes the reference date.
  final List<RegisteredEventEntity> current;

  /// Events that start after the reference date.
  final List<RegisteredEventEntity> upcoming;

  /// Events that ended before the reference date.
  final List<RegisteredEventEntity> past;

  /// Whether every bucket is empty.
  bool get isEmpty => current.isEmpty && upcoming.isEmpty && past.isEmpty;

  /// The most relevant currently active event (soonest ending).
  RegisteredEventEntity? get primaryCurrentEvent =>
      current.isEmpty ? null : current.first;

  /// The next event on the schedule (soonest starting).
  RegisteredEventEntity? get nextUpcomingEvent =>
      upcoming.isEmpty ? null : upcoming.first;

  /// Number of active events beyond [primaryCurrentEvent].
  int get additionalCurrentEventsCount =>
      current.length > 1 ? current.length - 1 : 0;

  @override
  List<Object?> get props => [current, upcoming, past];
}
