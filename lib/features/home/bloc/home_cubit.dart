import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_attendee/core/registered_events/get_my_registered_events_failure_message.dart';

part 'home_state.dart';

/// Manages the list of events the current user is registered for.
final class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required AttendeeRepository attendeeRepository})
      : _attendeeRepository = attendeeRepository,
        super(const HomeState());

  final AttendeeRepository _attendeeRepository;

  /// Loads the current user's registered events (all statuses, first page).
  Future<void> loadRegisteredEvents() async {
    emit(state.copyWith(loading: true, errorMessage: null));
    try {
      final events = await _attendeeRepository.getMyRegisteredEvents(
        status: 'all',
        page: 1,
        pageSize: 100,
      );
      emit(state.copyWith(events: events, loading: false, errorMessage: null));
    } on GetMyRegisteredEventsFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      emit(
        state.copyWith(
          loading: false,
          errorMessage: failure.toDisplayMessage(),
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          loading: false,
          errorMessage: GetMyRegisteredEventsUnknown().toDisplayMessage(),
        ),
      );
    }
  }
}
