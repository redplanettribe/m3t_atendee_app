import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_attendee/core/auth/auth_failure_message.dart';

part 'user_state.dart';

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
    emit(state.copyWith(loading: true, errorMessage: null));
    try {
      final user = await _authRepository.getCurrentUser();
      emit(state.copyWith(user: user, loading: false, errorMessage: null));
    } on AuthFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      emit(
        state.copyWith(
          loading: false,
          errorMessage: failure.toDisplayMessage(),
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          loading: false,
          errorMessage: UnknownError().toDisplayMessage(),
        ),
      );
    }
  }

  /// Updates the user's [name] and/or [lastName].
  ///
  /// At least one must be non-null.
  Future<void> updateProfile({String? name, String? lastName}) async {
    emit(state.copyWith(updatingProfile: true, errorMessage: null));
    try {
      final user = await _authRepository.updateCurrentUser(
        name: name,
        lastName: lastName,
      );
      emit(
        state.copyWith(user: user, updatingProfile: false, errorMessage: null),
      );
    } on AuthFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      emit(
        state.copyWith(
          updatingProfile: false,
          errorMessage: failure.toDisplayMessage(),
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          updatingProfile: false,
          errorMessage: UnknownError().toDisplayMessage(),
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
    emit(state.copyWith(updatingAvatar: true, errorMessage: null));
    try {
      final (uploadUrl, key) = await _authRepository.requestAvatarUpload();
      await _authRepository.uploadAvatar(
        uploadUrl: uploadUrl,
        bytes: bytes,
        contentType: contentType,
      );
      final user = await _authRepository.confirmAvatar(key: key);
      emit(
        state.copyWith(user: user, updatingAvatar: false, errorMessage: null),
      );
    } on AuthFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      emit(
        state.copyWith(
          updatingAvatar: false,
          errorMessage: failure.toDisplayMessage(),
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          updatingAvatar: false,
          errorMessage: UnknownError().toDisplayMessage(),
        ),
      );
    }
  }
}
