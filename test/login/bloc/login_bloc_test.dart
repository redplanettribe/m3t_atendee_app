import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_attendee/features/login/login.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('LoginBloc', () {
    late AuthRepository authRepository;

    const testEmail = 'test@example.com';
    const testCode = '123456';
    const testAuthUser = AuthUser(id: '1', email: testEmail);

    setUp(() {
      authRepository = _MockAuthRepository();
      when(
        () => authRepository.requestLoginCode(any()),
      ).thenAnswer((_) async {});
      when(
        () => authRepository.verifyLoginCode(
          email: any(named: 'email'),
          code: any(named: 'code'),
        ),
      ).thenAnswer((_) async => testAuthUser);
    });

    LoginBloc buildBloc() => LoginBloc(authRepository: authRepository);

    group('constructor', () {
      test('works properly', () => expect(buildBloc, returnsNormally));

      test('has correct initial state', () {
        expect(buildBloc().state, equals(const LoginState()));
      });
    });

    group('LoginEmailChanged', () {
      blocTest<LoginBloc, LoginState>(
        'emits state with updated email',
        build: buildBloc,
        act: (bloc) => bloc.add(const LoginEmailChanged(testEmail)),
        expect: () => const <LoginState>[LoginState(email: testEmail)],
      );

      blocTest<LoginBloc, LoginState>(
        'resets status to initial when email changes',
        build: buildBloc,
        seed: () => const LoginState(
          email: testEmail,
          status: LoginStatus.failure,
          errorMessage: 'some error',
        ),
        act: (bloc) => bloc.add(const LoginEmailChanged('new@example.com')),
        expect: () => const <LoginState>[
          LoginState(email: 'new@example.com'),
        ],
      );
    });

    group('LoginCodeRequested', () {
      blocTest<LoginBloc, LoginState>(
        'emits [loading, codeVerification] when request succeeds',
        build: buildBloc,
        seed: () => const LoginState(email: testEmail),
        act: (bloc) => bloc.add(const LoginCodeRequested()),
        expect: () => const <LoginState>[
          LoginState(email: testEmail, status: .loading),
          LoginState(email: testEmail, step: .codeVerification),
        ],
        verify: (_) {
          verify(() => authRepository.requestLoginCode(testEmail)).called(1);
        },
      );

      blocTest<LoginBloc, LoginState>(
        'emits [loading, failure] with network message when request fails',
        setUp: () {
          when(
            () => authRepository.requestLoginCode(any()),
          ).thenThrow(NetworkError());
        },
        build: buildBloc,
        seed: () => const LoginState(email: testEmail),
        act: (bloc) => bloc.add(const LoginCodeRequested()),
        expect: () => <LoginState>[
          const LoginState(email: testEmail, status: .loading),
          const LoginState(
            email: testEmail,
            status: .failure,
            errorMessage: 'A network error occurred. Please try again.',
          ),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits [loading, failure] with unknown message on unexpected error',
        setUp: () {
          when(
            () => authRepository.requestLoginCode(any()),
          ).thenThrow(UnknownError());
        },
        build: buildBloc,
        seed: () => const LoginState(email: testEmail),
        act: (bloc) => bloc.add(const LoginCodeRequested()),
        expect: () => <LoginState>[
          const LoginState(email: testEmail, status: .loading),
          const LoginState(
            email: testEmail,
            status: .failure,
            errorMessage: 'An unexpected error occurred. Please try again.',
          ),
        ],
      );
    });

    group('LoginCodeChanged', () {
      blocTest<LoginBloc, LoginState>(
        'emits state with updated code',
        build: buildBloc,
        seed: () => const LoginState(
          email: testEmail,
          step: .codeVerification,
        ),
        act: (bloc) => bloc.add(const LoginCodeChanged(testCode)),
        expect: () => const <LoginState>[
          LoginState(
            email: testEmail,
            step: .codeVerification,
            code: testCode,
          ),
        ],
      );
    });

    group('LoginCodeSubmitted', () {
      blocTest<LoginBloc, LoginState>(
        'emits [loading, success] when verification succeeds',
        build: buildBloc,
        seed: () => const LoginState(
          email: testEmail,
          step: .codeVerification,
          code: testCode,
        ),
        act: (bloc) => bloc.add(const LoginCodeSubmitted()),
        expect: () => const <LoginState>[
          LoginState(
            email: testEmail,
            step: .codeVerification,
            code: testCode,
            status: .loading,
          ),
          LoginState(
            email: testEmail,
            step: .codeVerification,
            code: testCode,
            status: .success,
          ),
        ],
        verify: (_) {
          verify(
            () => authRepository.verifyLoginCode(
              email: testEmail,
              code: testCode,
            ),
          ).called(1);
        },
      );

      blocTest<LoginBloc, LoginState>(
        'emits [loading, failure] with invalid code message when code is wrong',
        setUp: () {
          when(
            () => authRepository.verifyLoginCode(
              email: any(named: 'email'),
              code: any(named: 'code'),
            ),
          ).thenThrow(InvalidCode());
        },
        build: buildBloc,
        seed: () => const LoginState(
          email: testEmail,
          step: .codeVerification,
          code: testCode,
        ),
        act: (bloc) => bloc.add(const LoginCodeSubmitted()),
        expect: () => <LoginState>[
          const LoginState(
            email: testEmail,
            step: .codeVerification,
            code: testCode,
            status: .loading,
          ),
          const LoginState(
            email: testEmail,
            step: .codeVerification,
            code: testCode,
            status: .failure,
            errorMessage: 'The verification code is invalid.',
          ),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits [loading, failure] with network message on network error',
        setUp: () {
          when(
            () => authRepository.verifyLoginCode(
              email: any(named: 'email'),
              code: any(named: 'code'),
            ),
          ).thenThrow(NetworkError());
        },
        build: buildBloc,
        seed: () => const LoginState(
          email: testEmail,
          step: .codeVerification,
          code: testCode,
        ),
        act: (bloc) => bloc.add(const LoginCodeSubmitted()),
        expect: () => <LoginState>[
          const LoginState(
            email: testEmail,
            step: .codeVerification,
            code: testCode,
            status: .loading,
          ),
          const LoginState(
            email: testEmail,
            step: .codeVerification,
            code: testCode,
            status: .failure,
            errorMessage: 'A network error occurred. Please try again.',
          ),
        ],
      );
    });

    group('LoginStepBackToEmail', () {
      blocTest<LoginBloc, LoginState>(
        'resets step to emailEntry and clears code',
        build: buildBloc,
        seed: () => const LoginState(
          email: testEmail,
          step: .codeVerification,
          code: testCode,
        ),
        act: (bloc) => bloc.add(const LoginStepBackToEmail()),
        expect: () => const <LoginState>[LoginState(email: testEmail)],
      );
    });
  });
}
