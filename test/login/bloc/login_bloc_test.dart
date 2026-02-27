import 'package:auth_repository/auth_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_api/m3t_api.dart';
import 'package:m3t_attendee/login/login.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('LoginBloc', () {
    late AuthRepository authRepository;

    const testEmail = 'test@example.com';
    const testCode = '123456';
    const testLoginResponse = LoginResponse(
      token: 'jwt-token',
      tokenType: 'bearer',
      user: User(id: '1', email: testEmail),
    );

    setUp(() {
      authRepository = MockAuthRepository();
      when(() => authRepository.requestLoginCode(any()))
          .thenAnswer((_) async {});
      when(
        () => authRepository.verifyLoginCode(
          email: any(named: 'email'),
          code: any(named: 'code'),
        ),
      ).thenAnswer((_) async => testLoginResponse);
    });

    LoginBloc buildBloc() {
      return LoginBloc(authRepository: authRepository);
    }

    group('constructor', () {
      test('works properly', () => expect(buildBloc, returnsNormally));

      test('has correct initial state', () {
        expect(
          buildBloc().state,
          equals(const LoginState()),
        );
      });
    });

    group('LoginEmailChanged', () {
      blocTest<LoginBloc, LoginState>(
        'emits state with updated email',
        build: buildBloc,
        act: (bloc) => bloc.add(const LoginEmailChanged(testEmail)),
        expect: () => const <LoginState>[
          LoginState(email: testEmail),
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
          LoginState(
            email: testEmail,
            status: LoginStatus.loading,
          ),
          LoginState(
            email: testEmail,
            step: LoginStep.codeVerification,
            status: LoginStatus.initial,
          ),
        ],
        verify: (_) {
          verify(
            () => authRepository.requestLoginCode(testEmail),
          ).called(1);
        },
      );

      blocTest<LoginBloc, LoginState>(
        'emits [loading, failure] when request fails',
        setUp: () {
          when(() => authRepository.requestLoginCode(any()))
              .thenThrow(
            RequestLoginCodeFailure('bad_request'),
          );
        },
        build: buildBloc,
        seed: () => const LoginState(email: testEmail),
        act: (bloc) => bloc.add(const LoginCodeRequested()),
        expect: () => <LoginState>[
          const LoginState(
            email: testEmail,
            status: LoginStatus.loading,
          ),
          LoginState(
            email: testEmail,
            status: LoginStatus.failure,
            errorMessage:
                RequestLoginCodeFailure('bad_request').toString(),
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
          step: LoginStep.codeVerification,
        ),
        act: (bloc) => bloc.add(const LoginCodeChanged(testCode)),
        expect: () => const <LoginState>[
          LoginState(
            email: testEmail,
            step: LoginStep.codeVerification,
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
          step: LoginStep.codeVerification,
          code: testCode,
        ),
        act: (bloc) => bloc.add(const LoginCodeSubmitted()),
        expect: () => const <LoginState>[
          LoginState(
            email: testEmail,
            step: LoginStep.codeVerification,
            code: testCode,
            status: LoginStatus.loading,
          ),
          LoginState(
            email: testEmail,
            step: LoginStep.codeVerification,
            code: testCode,
            status: LoginStatus.success,
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
        'emits [loading, failure] when verification fails',
        setUp: () {
          when(
            () => authRepository.verifyLoginCode(
              email: any(named: 'email'),
              code: any(named: 'code'),
            ),
          ).thenThrow(
            VerifyLoginCodeFailure('unauthorized'),
          );
        },
        build: buildBloc,
        seed: () => const LoginState(
          email: testEmail,
          step: LoginStep.codeVerification,
          code: testCode,
        ),
        act: (bloc) => bloc.add(const LoginCodeSubmitted()),
        expect: () => <LoginState>[
          const LoginState(
            email: testEmail,
            step: LoginStep.codeVerification,
            code: testCode,
            status: LoginStatus.loading,
          ),
          LoginState(
            email: testEmail,
            step: LoginStep.codeVerification,
            code: testCode,
            status: LoginStatus.failure,
            errorMessage:
                VerifyLoginCodeFailure('unauthorized').toString(),
          ),
        ],
      );
    });

    group('LoginStepBackToEmail', () {
      blocTest<LoginBloc, LoginState>(
        'emits state reset to email entry step',
        build: buildBloc,
        seed: () => const LoginState(
          email: testEmail,
          step: LoginStep.codeVerification,
          code: testCode,
        ),
        act: (bloc) => bloc.add(const LoginStepBackToEmail()),
        expect: () => const <LoginState>[
          LoginState(
            email: testEmail,
            step: LoginStep.emailEntry,
            status: LoginStatus.initial,
          ),
        ],
      );
    });
  });
}
