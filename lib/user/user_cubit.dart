import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

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

  UserState copyWith({
    AuthUser? user,
    bool? loading,
    bool? updatingProfile,
    bool? updatingAvatar,

    /// Pass [clearError: true] to explicitly set [errorMessage] to null.
    bool clearError = false,
    String? errorMessage,
  }) {
    return UserState(
      user: user ?? this.user,
      loading: loading ?? this.loading,
      updatingProfile: updatingProfile ?? this.updatingProfile,
      updatingAvatar: updatingAvatar ?? this.updatingAvatar,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
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

// ---------------------------------------------------------------------------
// Cubit
// ---------------------------------------------------------------------------

/// Manages the authenticated user's profile state.
///
/// Depends on [AuthRepository] — the domain interface — so this class is
/// fully decoupled from network or storage implementation details.
final class UserCubit extends Cubit<UserState> {
  UserCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const UserState());

  final AuthRepository _authRepository;

  /// Loads the current user's profile from the repository.
  Future<void> loadCurrentUser() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final user = await _authRepository.getCurrentUser();
      emit(state.copyWith(user: user, loading: false, clearError: true));
    } on Object catch (error) {
      emit(
        state.copyWith(
          loading: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  /// Updates the user's [name] and/or [lastName].
  ///
  /// At least one must be non-null.
  Future<void> updateProfile({
    String? name,
    String? lastName,
  }) async {
    emit(state.copyWith(updatingProfile: true, clearError: true));
    try {
      final user = await _authRepository.updateCurrentUser(
        name: name,
        lastName: lastName,
      );
      emit(
        state.copyWith(user: user, updatingProfile: false, clearError: true),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          updatingProfile: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  /// Uploads new avatar [bytes] with the given [contentType].
  ///
  /// Orchestrates request-upload-confirm in a single atomic operation from
  /// the caller's perspective.
  Future<void> updateAvatar({
    required List<int> bytes,
    required String contentType,
  }) async {
    emit(state.copyWith(updatingAvatar: true, clearError: true));
    try {
      final (uploadUrl, key) = await _authRepository.requestAvatarUpload();
      await _authRepository.uploadAvatar(
        uploadUrl: uploadUrl,
        bytes: bytes,
        contentType: contentType,
      );
      final user = await _authRepository.confirmAvatar(key: key);
      emit(
        state.copyWith(user: user, updatingAvatar: false, clearError: true),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          updatingAvatar: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
