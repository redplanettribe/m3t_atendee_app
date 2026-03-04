import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_attendee/app/bloc/auth_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('AuthBloc', () {
    late _MockAuthRepository authRepository;
    late StreamController<AuthStatus> statusController;

    const testUser = AuthUser(id: '1', email: 'test@example.com');

    setUp(() {
      authRepository = _MockAuthRepository();
      statusController = StreamController<AuthStatus>.broadcast();
      when(
        () => authRepository.status,
      ).thenAnswer((_) => statusController.stream);
      when(() => authRepository.currentUser).thenReturn(null);
      when(() => authRepository.currentStatus).thenReturn(.unknown);
      when(() => authRepository.logout()).thenAnswer((_) async {});
      when(() => authRepository.dispose()).thenAnswer((_) async {});
    });

    tearDown(() async {
      await statusController.close();
    });

    AuthBloc buildBloc() => AuthBloc(authRepository: authRepository);

    test('initial state is AuthState(unknown)', () {
      expect(buildBloc().state, equals(const AuthState()));
    });

    group('AuthStatusChanged (via status stream)', () {
      blocTest<AuthBloc, AuthState>(
        'emits authenticated state with user when stream emits authenticated',
        setUp: () {
          when(() => authRepository.currentUser).thenReturn(testUser);
        },
        build: buildBloc,
        act: (bloc) => statusController.add(.authenticated),
        expect: () => const [
          AuthState(status: .authenticated, user: testUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits unauthenticated state with null user when stream emits '
        'unauthenticated',
        build: buildBloc,
        act: (bloc) => statusController.add(.unauthenticated),
        expect: () => const [
          AuthState(status: .unauthenticated),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'clears user when transitioning from authenticated to unauthenticated',
        setUp: () {
          when(() => authRepository.currentUser).thenReturn(null);
        },
        build: buildBloc,
        seed: () => const AuthState(
          status: .authenticated,
          user: testUser,
        ),
        act: (bloc) => statusController.add(.unauthenticated),
        expect: () => const [AuthState(status: .unauthenticated)],
      );

      blocTest<AuthBloc, AuthState>(
        'emits multiple transitions correctly',
        build: buildBloc,
        act: (bloc) async {
          statusController.add(.unauthenticated);
          await Future<void>.delayed(Duration.zero);
          when(() => authRepository.currentUser).thenReturn(testUser);
          statusController.add(.authenticated);
        },
        expect: () => const [
          AuthState(status: .unauthenticated),
          AuthState(status: .authenticated, user: testUser),
        ],
      );
    });

    group('AuthLogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'calls logout on repository',
        build: buildBloc,
        act: (bloc) => bloc.add(const AuthLogoutRequested()),
        verify: (_) {
          verify(() => authRepository.logout()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'does not emit state directly — state change comes from status stream',
        build: buildBloc,
        act: (bloc) => bloc.add(const AuthLogoutRequested()),
        expect: () => <AuthState>[],
      );

      blocTest<AuthBloc, AuthState>(
        'emits unauthenticated after logout when stream responds',
        build: buildBloc,
        act: (bloc) async {
          bloc.add(const AuthLogoutRequested());
          await Future<void>.delayed(Duration.zero);
          statusController.add(.unauthenticated);
        },
        expect: () => const [AuthState(status: .unauthenticated)],
        verify: (_) {
          verify(() => authRepository.logout()).called(1);
        },
      );
    });
  });
}
