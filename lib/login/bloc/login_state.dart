part of 'login_bloc.dart';

enum LoginStep { emailEntry, codeVerification }

enum LoginStatus { initial, loading, success, failure }

final class LoginState extends Equatable {
  const LoginState({
    this.step = .emailEntry,
    this.status = .initial,
    this.email = '',
    this.code = '',
    this.errorMessage,
  });

  final LoginStep step;
  final LoginStatus status;
  final String email;
  final String code;
  final String? errorMessage;

  LoginState copyWith({
    LoginStep? step,
    LoginStatus? status,
    String? email,
    String? code,
    Object? errorMessage = _sentinel,
  }) {
    return LoginState(
      step: step ?? this.step,
      status: status ?? this.status,
      email: email ?? this.email,
      code: code ?? this.code,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const _sentinel = Object();

  @override
  List<Object?> get props => [step, status, email, code, errorMessage];
}
