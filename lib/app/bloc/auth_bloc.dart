import 'dart:async';

import 'package:domain/domain.dart' show AuthRepository, AuthStatus, AuthUser;
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

final class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(
        AuthState(
          status: authRepository.currentStatus,
          user: authRepository.currentUser,
        ),
      ) {
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<AuthLogoutRequested>(_onLogoutRequested);
    _statusSubscription = authRepository.status.listen(
      (status) => add(AuthStatusChanged(status)),
    );
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<AuthStatus> _statusSubscription;

  Future<void> _onAuthStatusChanged(
    AuthStatusChanged event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      AuthState(
        status: event.status,
        user: event.status == .authenticated
            ? _authRepository.currentUser
            : null,
      ),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.logout();
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  @override
  Future<void> close() async {
    await _statusSubscription.cancel();
    await _authRepository.dispose();
    return super.close();
  }
}
