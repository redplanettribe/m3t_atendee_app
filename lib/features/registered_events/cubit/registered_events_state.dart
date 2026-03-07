part of 'registered_events_cubit.dart';

enum RegisteredEventsStatus { initial, loading, refreshing, loaded, failure }

/// Presentation-layer tab identifiers for the My Events screen.
///
/// Maps to domain-level [EventTimelineBucket] categories but remains
/// independent so screen structure does not leak into the domain.
enum RegisteredEventsTab { current, upcoming, past }

final class RegisteredEventsState extends Equatable {
  const RegisteredEventsState({
    this.timeline = RegisteredEventsTimeline.empty,
    this.status = .initial,
    this.errorMessage,
    this.selectedTab,
  });

  /// Precomputed temporal classification of the user's registered events.
  final RegisteredEventsTimeline timeline;
  final RegisteredEventsStatus status;
  final String? errorMessage;
  final RegisteredEventsTab? selectedTab;

  // ---------------------------------------------------------------------------
  // Presentation accessors — delegate to timeline
  // ---------------------------------------------------------------------------

  List<RegisteredEventEntity> get currentEvents => timeline.current;

  List<RegisteredEventEntity> get upcomingEvents => timeline.upcoming;

  List<RegisteredEventEntity> get pastEvents => timeline.past;

  RegisteredEventEntity? get primaryCurrentEvent =>
      timeline.primaryCurrentEvent;

  RegisteredEventEntity? get nextUpcomingEvent => timeline.nextUpcomingEvent;

  int get additionalCurrentEventsCount => timeline.additionalCurrentEventsCount;

  RegisteredEventsTab get effectiveSelectedTab {
    final tab = selectedTab;
    if (tab != null) return tab;
    if (currentEvents.isNotEmpty) return .current;
    if (upcomingEvents.isNotEmpty) return .upcoming;
    return .past;
  }

  // ---------------------------------------------------------------------------
  // copyWith / Equatable
  // ---------------------------------------------------------------------------

  static const _sentinel = Object();

  RegisteredEventsState copyWith({
    RegisteredEventsTimeline? timeline,
    RegisteredEventsStatus? status,
    Object? errorMessage = _sentinel,
    Object? selectedTab = _sentinel,
  }) {
    return RegisteredEventsState(
      timeline: timeline ?? this.timeline,
      status: status ?? this.status,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      selectedTab: selectedTab == _sentinel
          ? this.selectedTab
          : selectedTab as RegisteredEventsTab?,
    );
  }

  @override
  List<Object?> get props => [timeline, status, errorMessage, selectedTab];
}
