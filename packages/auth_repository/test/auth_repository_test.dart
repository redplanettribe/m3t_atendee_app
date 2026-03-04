import 'dart:async';

import 'package:auth_repository/auth_repository.dart';
import 'package:domain/domain.dart';
import 'package:m3t_api/m3t_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockM3tApiClient extends Mock implements M3tApiClient {}

class _MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  group('AuthRepositoryImpl', () {
    late _MockM3tApiClient apiClient;
    late _MockTokenStorage tokenStorage;
    late AuthRepositoryImpl repository;

    const testToken = 'test-jwt-token';
    const testEmail = 'user@example.com';
    const testCode = '123456';

    const testUser = User(id: '42', email: testEmail);
    const testLoginResponse = LoginResponse(
      token: testToken,
      tokenType: 'Bearer',
      user: testUser,
    );
    final testAuthUser = AuthUser(id: testUser.id, email: testUser.email);

    setUp(() {
      apiClient = _MockM3tApiClient();
      tokenStorage = _MockTokenStorage();
      repository = AuthRepositoryImpl(
        apiClient: apiClient,
        tokenStorage: tokenStorage,
      );
    });

    tearDown(() async {
      await repository.dispose();
    });

    // ─── initialize() ────────────────────────────────────────────────────────

    group('initialize()', () {
      test(
        'sets currentStatus to unauthenticated when no token is stored',
        () async {
          when(() => tokenStorage.read()).thenAnswer((_) async => null);

          final emitted = <AuthStatus>[];
          final sub = repository.status.listen(emitted.add);

          await repository.initialize();
          await Future<void>.delayed(Duration.zero);
          await sub.cancel();

          expect(repository.currentStatus, AuthStatus.unauthenticated);
          expect(emitted, equals([AuthStatus.unauthenticated]));
        },
      );

      test(
        'sets currentStatus to authenticated when a token is stored',
        () async {
          when(() => tokenStorage.read()).thenAnswer((_) async => testToken);

          final emitted = <AuthStatus>[];
          final sub = repository.status.listen(emitted.add);

          await repository.initialize();
          await Future<void>.delayed(Duration.zero);
          await sub.cancel();

          expect(repository.currentStatus, AuthStatus.authenticated);
          expect(emitted, equals([AuthStatus.authenticated]));
        },
      );

      test(
        'sets currentStatus to unauthenticated when storage throws',
        () async {
          when(
            () => tokenStorage.read(),
          ).thenThrow(Exception('storage unavailable'));

          final emitted = <AuthStatus>[];
          final sub = repository.status.listen(emitted.add);

          await repository.initialize();
          await Future<void>.delayed(Duration.zero);
          await sub.cancel();

          expect(repository.currentStatus, AuthStatus.unauthenticated);
          expect(emitted, equals([AuthStatus.unauthenticated]));
        },
      );
    });

    // ─── currentUser ─────────────────────────────────────────────────────────

    group('currentUser', () {
      test('is null before any login', () {
        expect(repository.currentUser, isNull);
      });

      test('is set after verifyLoginCode succeeds', () async {
        when(
          () => apiClient.verifyLoginCode(
            email: any(named: 'email'),
            code: any(named: 'code'),
          ),
        ).thenAnswer((_) async => testLoginResponse);
        when(() => tokenStorage.write(any())).thenAnswer((_) async {});

        await repository.verifyLoginCode(email: testEmail, code: testCode);

        expect(repository.currentUser, equals(testAuthUser));
      });

      test('is cleared after logout', () async {
        when(
          () => apiClient.verifyLoginCode(
            email: any(named: 'email'),
            code: any(named: 'code'),
          ),
        ).thenAnswer((_) async => testLoginResponse);
        when(() => tokenStorage.write(any())).thenAnswer((_) async {});
        when(() => tokenStorage.delete()).thenAnswer((_) async {});

        await repository.verifyLoginCode(email: testEmail, code: testCode);
        await repository.logout();

        expect(repository.currentUser, isNull);
      });
    });

    // ─── requestLoginCode() ──────────────────────────────────────────────────

    group('requestLoginCode()', () {
      test('delegates to the api client', () async {
        when(
          () => apiClient.requestLoginCode(any()),
        ).thenAnswer((_) async {});

        await repository.requestLoginCode(testEmail);

        verify(() => apiClient.requestLoginCode(testEmail)).called(1);
      });

      test(
        'throws NetworkError when api throws RequestLoginCodeFailure',
        () async {
          when(
            () => apiClient.requestLoginCode(any()),
          ).thenThrow(RequestLoginCodeFailure('network fail'));

          await expectLater(
            repository.requestLoginCode(testEmail),
            throwsA(isA<NetworkError>()),
          );
        },
      );

      test('throws UnknownError on unexpected exception', () async {
        when(
          () => apiClient.requestLoginCode(any()),
        ).thenThrow(Exception('unexpected'));

        await expectLater(
          repository.requestLoginCode(testEmail),
          throwsA(isA<UnknownError>()),
        );
      });
    });

    // ─── verifyLoginCode() ───────────────────────────────────────────────────

    group('verifyLoginCode()', () {
      setUp(() {
        when(() => tokenStorage.write(any())).thenAnswer((_) async {});
      });

      test('returns the mapped AuthUser on success', () async {
        when(
          () => apiClient.verifyLoginCode(
            email: any(named: 'email'),
            code: any(named: 'code'),
          ),
        ).thenAnswer((_) async => testLoginResponse);

        final result = await repository.verifyLoginCode(
          email: testEmail,
          code: testCode,
        );

        expect(result, equals(testAuthUser));
      });

      test('persists the token to secure storage', () async {
        when(
          () => apiClient.verifyLoginCode(
            email: any(named: 'email'),
            code: any(named: 'code'),
          ),
        ).thenAnswer((_) async => testLoginResponse);

        await repository.verifyLoginCode(email: testEmail, code: testCode);

        verify(() => tokenStorage.write(testToken)).called(1);
      });

      test('emits AuthStatus.authenticated on success', () async {
        when(
          () => apiClient.verifyLoginCode(
            email: any(named: 'email'),
            code: any(named: 'code'),
          ),
        ).thenAnswer((_) async => testLoginResponse);

        final emitted = <AuthStatus>[];
        final sub = repository.status.listen(emitted.add);

        await repository.verifyLoginCode(email: testEmail, code: testCode);
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();

        expect(emitted, contains(AuthStatus.authenticated));
      });

      test(
        'throws InvalidCode when api throws VerifyLoginCodeFailure',
        () async {
          when(
            () => apiClient.verifyLoginCode(
              email: any(named: 'email'),
              code: any(named: 'code'),
            ),
          ).thenThrow(VerifyLoginCodeFailure('bad code'));

          await expectLater(
            repository.verifyLoginCode(email: testEmail, code: testCode),
            throwsA(isA<InvalidCode>()),
          );
        },
      );

      test('throws UnknownError on unexpected exception', () async {
        when(
          () => apiClient.verifyLoginCode(
            email: any(named: 'email'),
            code: any(named: 'code'),
          ),
        ).thenThrow(Exception('unexpected'));

        await expectLater(
          repository.verifyLoginCode(email: testEmail, code: testCode),
          throwsA(isA<UnknownError>()),
        );
      });
    });

    // ─── logout() ────────────────────────────────────────────────────────────

    group('logout()', () {
      test('deletes the token from storage', () async {
        when(() => tokenStorage.delete()).thenAnswer((_) async {});

        await repository.logout();

        verify(() => tokenStorage.delete()).called(1);
      });

      test('emits AuthStatus.unauthenticated', () async {
        when(() => tokenStorage.delete()).thenAnswer((_) async {});

        final emitted = <AuthStatus>[];
        final sub = repository.status.listen(emitted.add);

        await repository.logout();
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();

        expect(emitted, contains(AuthStatus.unauthenticated));
      });

      test('sets currentStatus to unauthenticated', () async {
        when(() => tokenStorage.delete()).thenAnswer((_) async {});

        await repository.logout();

        expect(repository.currentStatus, AuthStatus.unauthenticated);
      });
    });

    // ─── dispose() ───────────────────────────────────────────────────────────

    group('dispose()', () {
      test('closes the status stream', () async {
        final done = Completer<void>();
        repository.status.listen(null, onDone: done.complete);

        await repository.dispose();

        await expectLater(done.future, completes);
      });
    });
  });
}
