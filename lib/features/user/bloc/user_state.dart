part of 'user_cubit.dart';

/// Immutable state for the user-profile feature.
///
/// [user] is `null` until the first successful load.
/// [errorMessage] is `null` when the last operation succeeded.
final class UserState extends Equatable {
  const UserState({
    this.user,
    this.loading = false,
    this.updatingProfile = false,
    this.updatingAvatar = false,
    this.errorMessage,
  });

  final AuthUser? user;
  final bool loading;
  final bool updatingProfile;
  final bool updatingAvatar;
  final String? errorMessage;

  static const _sentinel = Object();

  UserState copyWith({
    Object? user = _sentinel,
    bool? loading,
    bool? updatingProfile,
    bool? updatingAvatar,
    Object? errorMessage = _sentinel,
  }) {
    return UserState(
      user: user == _sentinel ? this.user : user as AuthUser?,
      loading: loading ?? this.loading,
      updatingProfile: updatingProfile ?? this.updatingProfile,
      updatingAvatar: updatingAvatar ?? this.updatingAvatar,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    user,
    loading,
    updatingProfile,
    updatingAvatar,
    errorMessage,
  ];
}
