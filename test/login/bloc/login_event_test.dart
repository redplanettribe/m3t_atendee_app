// ignore_for_file: prefer_const_constructors
import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_attendee/login/login.dart';

void main() {
  group('LoginEvent', () {
    group('LoginEmailChanged', () {
      test('supports value equality', () {
        expect(
          LoginEmailChanged('test@example.com'),
          equals(LoginEmailChanged('test@example.com')),
        );
      });

      test('props are correct', () {
        expect(
          LoginEmailChanged('test@example.com').props,
          equals(<Object?>['test@example.com']),
        );
      });
    });

    group('LoginCodeRequested', () {
      test('supports value equality', () {
        expect(
          LoginCodeRequested(),
          equals(LoginCodeRequested()),
        );
      });

      test('props are correct', () {
        expect(
          LoginCodeRequested().props,
          equals(<Object?>[]),
        );
      });
    });

    group('LoginCodeChanged', () {
      test('supports value equality', () {
        expect(
          LoginCodeChanged('123456'),
          equals(LoginCodeChanged('123456')),
        );
      });

      test('props are correct', () {
        expect(
          LoginCodeChanged('123456').props,
          equals(<Object?>['123456']),
        );
      });
    });

    group('LoginCodeSubmitted', () {
      test('supports value equality', () {
        expect(
          LoginCodeSubmitted(),
          equals(LoginCodeSubmitted()),
        );
      });

      test('props are correct', () {
        expect(
          LoginCodeSubmitted().props,
          equals(<Object?>[]),
        );
      });
    });

    group('LoginStepBackToEmail', () {
      test('supports value equality', () {
        expect(
          LoginStepBackToEmail(),
          equals(LoginStepBackToEmail()),
        );
      });

      test('props are correct', () {
        expect(
          LoginStepBackToEmail().props,
          equals(<Object?>[]),
        );
      });
    });
  });
}
