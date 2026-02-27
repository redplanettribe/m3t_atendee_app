part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

final class LoginEmailChanged extends LoginEvent {
  const LoginEmailChanged(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

final class LoginCodeRequested extends LoginEvent {
  const LoginCodeRequested();
}

final class LoginCodeChanged extends LoginEvent {
  const LoginCodeChanged(this.code);

  final String code;

  @override
  List<Object?> get props => [code];
}

final class LoginCodeSubmitted extends LoginEvent {
  const LoginCodeSubmitted();
}

final class LoginStepBackToEmail extends LoginEvent {
  const LoginStepBackToEmail();
}
