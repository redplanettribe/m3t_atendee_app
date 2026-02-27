part of 'login_bloc.dart';

enum LoginStep { emailEntry, codeVerification }

enum LoginStatus { initial, loading, success, failure }

final class LoginState extends Equatable {
  const LoginState({
    this.step = LoginStep.emailEntry,
    this.status = LoginStatus.initial,
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
    LoginStep Function()? step,
    LoginStatus Function()? status,
    String Function()? email,
    String Function()? code,
    String? Function()? errorMessage,
  }) {
    return LoginState(
      step: step != null ? step() : this.step,
      status: status != null ? status() : this.status,
      email: email != null ? email() : this.email,
      code: code != null ? code() : this.code,
      errorMessage:
          errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [step, status, email, code, errorMessage];
}
