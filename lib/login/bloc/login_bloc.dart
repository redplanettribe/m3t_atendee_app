import 'package:auth_repository/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  void _onEmailChanged(
    LoginEmailChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(
      email: () => event.email,
      status: () => LoginStatus.initial,
      errorMessage: () => null,
    ));
  }

  Future<void> _onCodeRequested(
    LoginCodeRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(
      status: () => LoginStatus.loading,
      errorMessage: () => null,
    ));

    try {
      await _authRepository.requestLoginCode(state.email);
      emit(state.copyWith(
        step: () => LoginStep.codeVerification,
        status: () => LoginStatus.initial,
      ));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(
        status: () => LoginStatus.failure,
        errorMessage: () => error.toString(),
      ));
    }
  }

  void _onCodeChanged(
    LoginCodeChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(
      code: () => event.code,
      status: () => LoginStatus.initial,
      errorMessage: () => null,
    ));
  }

  Future<void> _onCodeSubmitted(
    LoginCodeSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(
      status: () => LoginStatus.loading,
      errorMessage: () => null,
    ));

    try {
      await _authRepository.verifyLoginCode(
        email: state.email,
        code: state.code,
      );
      emit(state.copyWith(status: () => LoginStatus.success));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(
        status: () => LoginStatus.failure,
        errorMessage: () => error.toString(),
      ));
    }
  }

  void _onStepBackToEmail(
    LoginStepBackToEmail event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(
      step: () => LoginStep.emailEntry,
      status: () => LoginStatus.initial,
      code: () => '',
      errorMessage: () => null,
    ));
  }
}
