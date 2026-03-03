import 'package:auth_repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_api/m3t_api.dart';

class UserState {
  const UserState({
    this.user,
    this.loading = false,
    this.updatingProfile = false,
    this.updatingAvatar = false,
    this.errorMessage,
  });

  final User? user;
  final bool loading;
  final bool updatingProfile;
  final bool updatingAvatar;
  final String? errorMessage;

  UserState copyWith({
    User? user,
    bool? loading,
    bool? updatingProfile,
    bool? updatingAvatar,
    String? errorMessage,
  }) {
    return UserState(
      user: user ?? this.user,
      loading: loading ?? this.loading,
      updatingProfile: updatingProfile ?? this.updatingProfile,
      updatingAvatar: updatingAvatar ?? this.updatingAvatar,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class UserCubit extends Cubit<UserState> {
  UserCubit(this._authRepository) : super(const UserState());

  final AuthRepository _authRepository;

  Future<void> loadCurrentUser() async {
    emit(state.copyWith(loading: true));
    try {
      final user = await _authRepository.getCurrentUser();
      emit(
        state.copyWith(
          user: user,
          loading: false,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          loading: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> updateProfile({
    String? name,
    String? lastName,
  }) async {
    emit(
      state.copyWith(
        updatingProfile: true,
        errorMessage: null,
      ),
    );
    try {
      final user = await _authRepository.updateCurrentUser(
        name: name,
        lastName: lastName,
      );
      emit(
        state.copyWith(
          user: user,
          updatingProfile: false,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          updatingProfile: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> updateAvatar({
    required List<int> bytes,
    required String contentType,
  }) async {
    emit(
      state.copyWith(
        updatingAvatar: true,
        errorMessage: null,
      ),
    );
    try {
      final uploadInfo = await _authRepository.requestAvatarUpload();

      final (uploadUrl, key) = uploadInfo;

      await _authRepository.uploadAvatar(
        uploadUrl: uploadUrl,
        bytes: bytes,
        contentType: contentType,
      );

      final user = await _authRepository.confirmAvatar(key: key);

      emit(
        state.copyWith(
          user: user,
          updatingAvatar: false,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          updatingAvatar: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}

