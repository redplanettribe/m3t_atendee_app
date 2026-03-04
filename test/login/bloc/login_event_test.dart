import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_attendee/login/login.dart';

void main() {
  group('LoginEvent', () {
    group('LoginEmailChanged', () {
      test('supports value equality', () {
        expect(
          const LoginEmailChanged('test@example.com'),
          equals(const LoginEmailChanged('test@example.com')),
        );
      });

      test('props are correct', () {
        expect(
          const LoginEmailChanged('test@example.com').props,
          equals(<Object?>['test@example.com']),
        );
      });
    });

    group('LoginCodeRequested', () {
      test('supports value equality', () {
        expect(
          const LoginCodeRequested(),
          equals(const LoginCodeRequested()),
        );
      });

      test('props are correct', () {
        expect(
          const LoginCodeRequested().props,
          equals(<Object?>[]),
        );
      });
    });

    group('LoginCodeChanged', () {
      test('supports value equality', () {
        expect(
          const LoginCodeChanged('123456'),
          equals(const LoginCodeChanged('123456')),
        );
      });

      test('props are correct', () {
        expect(
          const LoginCodeChanged('123456').props,
          equals(<Object?>['123456']),
        );
      });
    });

    group('LoginCodeSubmitted', () {
      test('supports value equality', () {
        expect(
          const LoginCodeSubmitted(),
          equals(const LoginCodeSubmitted()),
        );
      });

      test('props are correct', () {
        expect(
          const LoginCodeSubmitted().props,
          equals(<Object?>[]),
        );
      });
    });

    group('LoginStepBackToEmail', () {
      test('supports value equality', () {
        expect(
          const LoginStepBackToEmail(),
          equals(const LoginStepBackToEmail()),
        );
      });

      test('props are correct', () {
        expect(
          const LoginStepBackToEmail().props,
          equals(<Object?>[]),
        );
      });
    });
  });
}
