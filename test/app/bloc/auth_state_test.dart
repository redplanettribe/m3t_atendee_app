import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_attendee/app/bloc/auth_bloc.dart';

void main() {
  group('AuthState', () {
    const testUser = AuthUser(id: '1', email: 'test@example.com');

    AuthState createSubject({
      AuthStatus status = .unknown,
      AuthUser? user,
    }) {
      return AuthState(status: status, user: user);
    }

    test('supports value equality', () {
      expect(createSubject(), equals(createSubject()));
    });

    test('default status is unknown', () {
      expect(const AuthState().status, equals(AuthStatus.unknown));
    });

    test('default user is null', () {
      expect(const AuthState().user, isNull);
    });

    test('props are correct', () {
      expect(
        createSubject(status: .authenticated, user: testUser).props,
        equals(<Object?>[AuthStatus.authenticated, testUser]),
      );
    });

    group('copyWith', () {
      test('returns same object when no arguments are provided', () {
        expect(createSubject().copyWith(), equals(createSubject()));
      });

      test('retains existing user when user is not passed', () {
        final subject = createSubject(
          status: .authenticated,
          user: testUser,
        );
        expect(
          subject.copyWith(status: .unauthenticated),
          equals(
            createSubject(
              status: .unauthenticated,
              user: testUser,
            ),
          ),
        );
      });

      test('replaces every non-null parameter', () {
        expect(
          createSubject().copyWith(
            status: .authenticated,
            user: testUser,
          ),
          equals(
            createSubject(status: .authenticated, user: testUser),
          ),
        );
      });
    });
  });
}
