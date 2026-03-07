import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_attendee/core/registered_events/get_my_registered_events_failure_message.dart';

part 'registered_events_state.dart';

final class RegisteredEventsCubit extends Cubit<RegisteredEventsState> {
  RegisteredEventsCubit({required AttendeeRepository attendeeRepository})
    : _attendeeRepository = attendeeRepository,
      super(const RegisteredEventsState());

  final AttendeeRepository _attendeeRepository;

  /// Called once at app root. Reads cache first (zero latency),
  /// then fetches fresh data from the network.
  Future<void> initialize() async {
    RegisteredEventsTimeline timeline;
    try {
      timeline = _classifyEvents(
        _attendeeRepository.getCachedRegisteredEvents(),
      );
    } on Object catch (error, stackTrace) {
      // Cache read failed — most likely a schema-migration CastError
      // (e.g. a legacy record with a null startDate after the field became
      // non-nullable). Wipe the corrupt box and fall through to a clean
      // network fetch so the user is never stuck.
      addError(error, stackTrace);
      await _attendeeRepository.clearCache();
      timeline = .empty;
    }
    emit(
      state.copyWith(
        timeline: timeline,
        status: timeline.isEmpty ? .loading : .refreshing,
        errorMessage: null,
      ),
    );
    await _fetch();
  }

  /// On-demand refresh — called by pull-to-refresh and post-registration.
  Future<void> refresh() async {
    emit(
      state.copyWith(
        status: state.timeline.isEmpty ? .loading : .refreshing,
        errorMessage: null,
      ),
    );
    await _fetch();
  }

  void selectTab(RegisteredEventsTab tab) {
    if (state.selectedTab == tab) return;

    emit(state.copyWith(selectedTab: tab));
  }

  /// Clears local cache and resets to initial.
  Future<void> clear() async {
    await _attendeeRepository.clearCache();
    emit(const RegisteredEventsState());
  }

  Future<void> _fetch() async {
    try {
      final events = await _attendeeRepository.getMyRegisteredEvents(
        status: 'all',
        page: 1,
        pageSize: 100,
      );
      emit(
        state.copyWith(
          timeline: _classifyEvents(events),
          status: .loaded,
          errorMessage: null,
        ),
      );
    } on GetMyRegisteredEventsFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      emit(
        state.copyWith(
          status: .failure,
          errorMessage: failure.toDisplayMessage(),
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          status: .failure,
          errorMessage: GetMyRegisteredEventsUnknown().toDisplayMessage(),
        ),
      );
    }
  }

  static RegisteredEventsTimeline _classifyEvents(
    List<RegisteredEventEntity> events,
  ) => RegisteredEventsTimelineClassifier.classify(
    events,
    referenceDate: DateTime.now(),
  );
}
