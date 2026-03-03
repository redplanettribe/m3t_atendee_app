import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_attendee/core/auth/auth_failure_message.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginCodeRequested>(_onCodeRequested);
    on<LoginCodeChanged>(_onCodeChanged);
    on<LoginCodeSubmitted>(_onCodeSubmitted);
    on<LoginStepBackToEmail>(_onStepBackToEmail);
  }

  final AuthRepository _authRepository;

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    emit(
      state.copyWith(
        email: event.email,
        status: .initial,
        errorMessage: null,
      ),
    );
  }

  Future<void> _onCodeRequested(
    LoginCodeRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: .loading));

    try {
      await _authRepository.requestLoginCode(state.email);
      emit(state.copyWith(step: .codeVerification, status: .initial));
    } on AuthFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      emit(
        state.copyWith(
          status: .failure,
          errorMessage: failure.toDisplayMessage(),
        ),
      );
    }
  }

  void _onCodeChanged(LoginCodeChanged event, Emitter<LoginState> emit) {
    emit(
      state.copyWith(
        code: event.code,
        status: .initial,
        errorMessage: null,
      ),
    );
  }

  Future<void> _onCodeSubmitted(
    LoginCodeSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: .loading));

    try {
      await _authRepository.verifyLoginCode(
        email: state.email,
        code: state.code,
      );

      emit(state.copyWith(status: .success));
    } on AuthFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      emit(
        state.copyWith(
          status: .failure,
          errorMessage: failure.toDisplayMessage(),
        ),
      );
    }
  }

  void _onStepBackToEmail(
    LoginStepBackToEmail event,
    Emitter<LoginState> emit,
  ) {
    emit(
      state.copyWith(
        step: .emailEntry,
        status: .initial,
        code: '',
      ),
    );
  }
}
