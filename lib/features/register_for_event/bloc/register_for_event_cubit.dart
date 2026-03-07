import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_attendee/core/registration/registration_failure_message.dart';

part 'register_for_event_state.dart';

final class RegisterForEventCubit extends Cubit<RegisterForEventState> {
  RegisterForEventCubit({required AttendeeRepository attendeeRepository})
    : _attendeeRepository = attendeeRepository,
      super(const RegisterForEventState());

  final AttendeeRepository _attendeeRepository;

  /// Updates the event code as the user types.
  ///
  /// Normalizes to uppercase and trims whitespace. Resets status to
  /// initial and clears any previous error message.
  void eventCodeChanged(String value) {
    emit(
      state.copyWith(
        eventCode: value.trim().toUpperCase(),
        status: .initial,
        errorMessage: null,
      ),
    );
  }

  /// Validates and submits the event code via [AttendeeRepository].
  ///
  /// Emits loading while the request is in flight, success on completion,
  /// or failure with a user-facing error message on [RegistrationFailure].
  Future<void> submit() async {
    final code = state.eventCode;
    if (code.length != 4) {
      emit(
        state.copyWith(
          status: .failure,
          errorMessage: 'Please enter a 4-character event code.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: .loading,
        errorMessage: null,
      ),
    );

    try {
      await _attendeeRepository.registerForEventByCode(code);
      emit(state.copyWith(status: .success));
    } on RegistrationFailure catch (failure, stackTrace) {
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
          errorMessage: const RegistrationUnknownError().toDisplayMessage(),
        ),
      );
    }
  }
}
