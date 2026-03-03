part of 'auth_bloc.dart';

final class AuthState extends Equatable {
  const AuthState({
    this.status = .unknown,
    this.user,
  });

  final AuthStatus status;
  final AuthUser? user;

  AuthState copyWith({
    AuthStatus? status,
    Object? user = _sentinel,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user == _sentinel ? this.user : user as AuthUser?,
    );
  }

  static const _sentinel = Object();

  @override
  List<Object?> get props => [status, user];
}
