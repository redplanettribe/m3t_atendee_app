import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_attendee/app/bloc/auth_bloc.dart';

void main() {
  group('AuthEvent', () {
    group('AuthStatusChanged', () {
      test('supports value equality', () {
        expect(
          const AuthStatusChanged(.authenticated),
          equals(const AuthStatusChanged(.authenticated)),
        );
      });

      test('props are correct', () {
        expect(
          const AuthStatusChanged(.unauthenticated).props,
          equals(<Object>[AuthStatus.unauthenticated]),
        );
      });
    });

    group('AuthLogoutRequested', () {
      test('supports value equality', () {
        expect(
          const AuthLogoutRequested(),
          equals(const AuthLogoutRequested()),
        );
      });

      test('props are correct', () {
        expect(const AuthLogoutRequested().props, equals(<Object>[]));
      });
    });
  });
}
