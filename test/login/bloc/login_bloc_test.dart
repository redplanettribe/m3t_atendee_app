import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_api/m3t_api.dart'
    show RequestLoginCodeFailure, VerifyLoginCodeFailure;
import 'package:m3t_attendee/login/login.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('LoginBloc', () {
    late AuthRepository authRepository;

    const testEmail = 'test@example.com';
    const testCode = '123456';
    const testUser = AuthUser(id: '1', email: testEmail);

    setUp(() {
      authRepository = MockAuthRepository();
      when(
        () => authRepository.requestLoginCode(any()),
      ).thenAnswer((_) async {});
      when(
        () => authRepository.verifyLoginCode(
          email: any(named: 'email'),
          code: any(named: 'code'),
        ),
      ).thenAnswer((_) async => testUser);
    });

    LoginBloc buildBloc() {
      return LoginBloc(authRepository: authRepository);
    }

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
    });

    group('LoginCodeRequested', () {
      blocTest<LoginBloc, LoginState>(
        'emits [loading, codeVerification] when request succeeds',
        build: buildBloc,
        seed: () => const LoginState(email: testEmail),
        act: (bloc) => bloc.add(const LoginCodeRequested()),
        expect: () => const <LoginState>[
          LoginState(email: testEmail, status: .loading),
          LoginState(
            email: testEmail,
            step: .codeVerification,
          ),
        ],
        verify: (_) {
          verify(() => authRepository.requestLoginCode(testEmail)).called(1);
        },
      );

      blocTest<LoginBloc, LoginState>(
        'emits [loading, failure] when request fails',
        setUp: () {
          when(
            () => authRepository.requestLoginCode(any()),
          ).thenThrow(RequestLoginCodeFailure('bad_request'));
        },
        build: buildBloc,
        seed: () => const LoginState(email: testEmail),
        act: (bloc) => bloc.add(const LoginCodeRequested()),
        expect: () => <LoginState>[
          const LoginState(email: testEmail, status: .loading),
          LoginState(
            email: testEmail,
            status: .failure,
            errorMessage: RequestLoginCodeFailure('bad_request').toString(),
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
        'emits [loading, failure] when verification fails',
        setUp: () {
          when(
            () => authRepository.verifyLoginCode(
              email: any(named: 'email'),
              code: any(named: 'code'),
            ),
          ).thenThrow(VerifyLoginCodeFailure('unauthorized'));
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
          LoginState(
            email: testEmail,
            step: .codeVerification,
            code: testCode,
            status: .failure,
            errorMessage: VerifyLoginCodeFailure('unauthorized').toString(),
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
          step: .codeVerification,
          code: testCode,
        ),
        act: (bloc) => bloc.add(const LoginStepBackToEmail()),
        expect: () => const <LoginState>[
          LoginState(
            email: testEmail,
          ),
        ],
      );
    });
  });
}
