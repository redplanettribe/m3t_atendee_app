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
      expect(
        createSubject(),
        equals(createSubject()),
      );
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
        expect(
          createSubject().copyWith(),
          equals(createSubject()),
        );
      });

      test(
        'retains the old value for every parameter if null is provided',
        () {
          expect(
            createSubject().copyWith(),
            equals(createSubject()),
          );
        },
      );

      test('replaces every non-null parameter', () {
        expect(
          createSubject().copyWith(
            step: () => .codeVerification,
            status: () => .success,
            email: () => 'new@example.com',
            code: () => '654321',
            errorMessage: () => 'new error',
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
