import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_attendee/user/user_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('UserCubit', () {
    late AuthRepository authRepository;

    const user = AuthUser(id: '1', email: 'user@example.com');

    setUpAll(() {
      registerFallbackValue(Uri());
    });

    setUp(() {
      authRepository = _MockAuthRepository();
    });

    UserCubit buildCubit() => UserCubit(authRepository: authRepository);

    group('loadCurrentUser', () {
      blocTest<UserCubit, UserState>(
        'emits loading true then user when successful',
        build: buildCubit,
        setUp: () {
          when(
            () => authRepository.getCurrentUser(),
          ).thenAnswer((_) async => user);
        },
        act: (cubit) => cubit.loadCurrentUser(),
        expect: () => <UserState>[
          const UserState(loading: true),
          const UserState(user: user),
        ],
      );

      blocTest<UserCubit, UserState>(
        'emits loading false and errorMessage when failure',
        build: buildCubit,
        setUp: () {
          when(
            () => authRepository.getCurrentUser(),
          ).thenThrow(Exception('failed'));
        },
        act: (cubit) => cubit.loadCurrentUser(),
        expect: () => <UserState>[
          const UserState(loading: true),
          const UserState(errorMessage: 'Exception: failed'),
        ],
      );
    });

    group('updateProfile', () {
      const updatedUser = AuthUser(
        id: '1',
        email: 'user@example.com',
        name: 'New',
        lastName: 'Name',
      );

      blocTest<UserCubit, UserState>(
        'emits updatingProfile and updated user on success',
        build: buildCubit,
        setUp: () {
          when(
            () => authRepository.updateCurrentUser(
              name: any(named: 'name'),
              lastName: any(named: 'lastName'),
            ),
          ).thenAnswer((_) async => updatedUser);
        },
        act: (cubit) => cubit.updateProfile(name: 'New', lastName: 'Name'),
        expect: () => <UserState>[
          const UserState(
            updatingProfile: true,
          ),
          const UserState(
            user: updatedUser,
          ),
        ],
      );
    });

    group('updateAvatar', () {
      const updatedUser = AuthUser(
        id: '1',
        email: 'user@example.com',
        profilePictureUrl: 'url',
      );

      blocTest<UserCubit, UserState>(
        'goes through upload flow and updates user',
        build: buildCubit,
        setUp: () {
          when(() => authRepository.requestAvatarUpload()).thenAnswer(
            (_) async => (Uri.parse('https://upload'), 'key'),
          );
          when(
            () => authRepository.uploadAvatar(
              uploadUrl: any(named: 'uploadUrl'),
              bytes: any(named: 'bytes'),
              contentType: any(named: 'contentType'),
            ),
          ).thenAnswer((_) async {});
          when(
            () => authRepository.confirmAvatar(key: any(named: 'key')),
          ).thenAnswer((_) async => updatedUser);
        },
        act: (cubit) => cubit.updateAvatar(
          bytes: [1, 2, 3],
          contentType: 'image/png',
        ),
        expect: () => <UserState>[
          const UserState(
            updatingAvatar: true,
          ),
          const UserState(
            user: updatedUser,
          ),
        ],
      );
    });
  });
}
