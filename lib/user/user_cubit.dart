import 'package:auth_repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_api/m3t_api.dart';

class UserState {
  const UserState({
    this.user,
    this.loading = false,
  });

  final User? user;
  final bool loading;

  UserState copyWith({
    User? user,
    bool? loading,
  }) {
    return UserState(
      user: user ?? this.user,
      loading: loading ?? this.loading,
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
      emit(UserState(user: user, loading: false));
    } catch (_) {
      emit(state.copyWith(loading: false));
    }
  }
}

