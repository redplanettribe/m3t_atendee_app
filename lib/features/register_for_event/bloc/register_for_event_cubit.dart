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

  void eventCodeChanged(String value) {
    emit(
      state.copyWith(
        eventCode: value,
        status: RegisterForEventStatus.initial,
        errorMessage: null,
      ),
    );
  }

  Future<void> submit() async {
    final code = state.eventCode.trim().toUpperCase();
    if (code.length != 4) {
      emit(
        state.copyWith(
          status: RegisterForEventStatus.failure,
          errorMessage: 'Please enter a 4-character event code.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: RegisterForEventStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      await _attendeeRepository.registerForEventByCode(code);
      emit(state.copyWith(status: RegisterForEventStatus.success));
    } on RegistrationFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      emit(
        state.copyWith(
          status: RegisterForEventStatus.failure,
          errorMessage: failure.toDisplayMessage(),
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          status: RegisterForEventStatus.failure,
          errorMessage: RegistrationUnknownError().toDisplayMessage(),
        ),
      );
    }
  }
}
