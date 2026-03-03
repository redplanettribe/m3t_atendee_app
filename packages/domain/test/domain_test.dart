import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  group('AuthUser', () {
    final createdAt = DateTime(2024);
    final updatedAt = DateTime(2024, 6);

    AuthUser createSubject({
      String id = '1',
      String email = 'test@example.com',
      String? name,
      String? lastName,
      DateTime? createdAt,
      DateTime? updatedAt,
    }) {
      return AuthUser(
        id: id,
        email: email,
        name: name,
        lastName: lastName,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    }

    test('supports value equality', () {
      expect(createSubject(), equals(createSubject()));
    });

    test('instances with different ids are not equal', () {
      expect(createSubject(), isNot(equals(createSubject(id: '2'))));
    });

    test('props include all fields', () {
      expect(
        createSubject(
          name: 'John',
          lastName: 'Doe',
          createdAt: createdAt,
          updatedAt: updatedAt,
        ).props,
        equals(<Object?>[
          '1',
          'test@example.com',
          'John',
          'Doe',
          createdAt,
          updatedAt,
        ]),
      );
    });

    test('optional fields default to null', () {
      final user = createSubject();
      expect(user.name, isNull);
      expect(user.lastName, isNull);
      expect(user.createdAt, isNull);
      expect(user.updatedAt, isNull);
    });

    group('copyWith', () {
      test('returns same object when no arguments are provided', () {
        expect(createSubject().copyWith(), equals(createSubject()));
      });

      test('replaces every provided field', () {
        final original = createSubject();
        final copy = original.copyWith(
          id: '99',
          email: 'new@example.com',
          name: 'Jane',
          lastName: 'Smith',
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        expect(
          copy,
          equals(
            AuthUser(
              id: '99',
              email: 'new@example.com',
              name: 'Jane',
              lastName: 'Smith',
              createdAt: createdAt,
              updatedAt: updatedAt,
            ),
          ),
        );
      });

      test('retains existing values when fields are not provided', () {
        final original = createSubject(
          name: 'Alice',
          lastName: 'Liddell',
          createdAt: createdAt,
        );
        final copy = original.copyWith(email: 'updated@example.com');
        expect(copy.name, equals('Alice'));
        expect(copy.lastName, equals('Liddell'));
        expect(copy.createdAt, equals(createdAt));
      });
    });
  });

  group('AuthStatus', () {
    test('has three values', () {
      expect(AuthStatus.values, hasLength(3));
    });

    test('contains unknown, authenticated and unauthenticated', () {
      expect(
        AuthStatus.values,
        containsAll(const [
          AuthStatus.unknown,
          AuthStatus.authenticated,
          AuthStatus.unauthenticated,
        ]),
      );
    });
  });

  group('AuthFailure', () {
    test('InvalidEmail is an AuthFailure', () {
      expect(InvalidEmail(), isA<AuthFailure>());
    });

    test('InvalidCode is an AuthFailure', () {
      expect(InvalidCode(), isA<AuthFailure>());
    });

    test('NetworkError is an AuthFailure', () {
      expect(NetworkError(), isA<AuthFailure>());
    });

    test('UnknownError is an AuthFailure', () {
      expect(UnknownError(), isA<AuthFailure>());
    });

    test('AuthFailure implements Exception', () {
      expect(InvalidEmail(), isA<Exception>());
      expect(InvalidCode(), isA<Exception>());
      expect(NetworkError(), isA<Exception>());
      expect(UnknownError(), isA<Exception>());
    });

    test(
      'exhaustive switch over sealed class compiles and covers all variants',
      () {
        String describe(AuthFailure f) => switch (f) {
          InvalidEmail() => 'invalid_email',
          InvalidCode() => 'invalid_code',
          NetworkError() => 'network_error',
          UnknownError() => 'unknown_error',
        };

        expect(describe(InvalidEmail()), equals('invalid_email'));
        expect(describe(InvalidCode()), equals('invalid_code'));
        expect(describe(NetworkError()), equals('network_error'));
        expect(describe(UnknownError()), equals('unknown_error'));
      },
    );
  });
}
