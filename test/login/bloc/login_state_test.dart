import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_attendee/login/login.dart';

void main() {
  group('LoginState', () {
    LoginState createSubject({
      LoginStep step = .emailEntry,
      LoginStatus status = .initial,
      String email = '',
      String code = '',
      String? errorMessage,
    }) {
      return LoginState(
        step: step,
        status: status,
        email: email,
        code: code,
        errorMessage: errorMessage,
      );
    }

    test('supports value equality', () {
      expect(createSubject(), equals(createSubject()));
    });

    test('props are correct', () {
      expect(
        createSubject(
          email: 'test@example.com',
          code: '123456',
          errorMessage: 'error',
        ).props,
        equals(<Object?>[
          LoginStep.emailEntry,
          LoginStatus.initial,
          'test@example.com',
          '123456',
          'error',
        ]),
      );
    });

    group('copyWith', () {
      test('returns the same object if no arguments are provided', () {
        expect(createSubject().copyWith(), equals(createSubject()));
      });

      test('retains existing errorMessage when errorMessage is not passed', () {
        final subject = createSubject(errorMessage: 'existing error');
        expect(
          subject.copyWith(status: .loading),
          equals(
            createSubject(
              status: .loading,
              errorMessage: 'existing error',
            ),
          ),
        );
      });

      test('clears errorMessage when null is explicitly passed', () {
        final subject = createSubject(errorMessage: 'existing error');
        expect(
          subject.copyWith(errorMessage: null),
          equals(createSubject()),
        );
      });

      test('replaces every non-null parameter', () {
        expect(
          createSubject().copyWith(
            step: .codeVerification,
            status: .success,
            email: 'new@example.com',
            code: '654321',
            errorMessage: 'new error',
          ),
          equals(
            createSubject(
              step: .codeVerification,
              status: .success,
              email: 'new@example.com',
              code: '654321',
              errorMessage: 'new error',
            ),
          ),
        );
      });
    });
  });
}
