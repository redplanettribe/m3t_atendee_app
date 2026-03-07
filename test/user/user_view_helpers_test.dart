import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_attendee/core/app_config.dart';
import 'package:m3t_attendee/features/user/user.dart';

void main() {
  group('UserDisplayExtension.initials', () {
    test('returns ? for null user', () {
      const AuthUser? user = null;
      expect(user.initials, '?');
    });

    test('uses first letter of name and lastName when both present', () {
      const user = AuthUser(
        id: '1',
        email: 'x@y.com',
        name: 'Alice',
        lastName: 'Brown',
      );
      expect(user.initials, 'AB');
    });

    test('name + lastName are trimmed before use', () {
      const user = AuthUser(
        id: '1',
        email: 'x@y.com',
        name: '  alice  ',
        lastName: '  brown  ',
      );
      expect(user.initials, 'AB');
    });

    test('uses first 2 chars of name when lastName is absent', () {
      const user = AuthUser(id: '1', email: 'x@y.com', name: 'Alice');
      expect(user.initials, 'AL');
    });

    test('uses single char of name when name is 1 char', () {
      const user = AuthUser(id: '1', email: 'x@y.com', name: 'A');
      expect(user.initials, 'A');
    });

    test('falls back to email local-part first 2 chars', () {
      const user = AuthUser(id: '1', email: 'charlie@domain.com');
      expect(user.initials, 'CH');
    });

    test('falls back to single email char when local-part is 1 char', () {
      const user = AuthUser(id: '1', email: 'a@b.com');
      expect(user.initials, 'A');
    });

    test('returns ? when email is empty and no name', () {
      // AuthUser requires email but it could be empty in edge scenarios.
      const user = AuthUser(id: '1', email: '');
      expect(user.initials, '?');
    });
  });

  group('UserDisplayExtension.resolvedProfilePictureUrl', () {
    test('returns null for null user', () {
      const AuthUser? user = null;
      expect(user.resolvedProfilePictureUrl, isNull);
    });

    test('returns null for empty profile picture URL', () {
      const user = AuthUser(id: '1', email: 'x@y.com', profilePictureUrl: '');
      expect(user.resolvedProfilePictureUrl, isNull);
    });

    test('resolves relative paths against AppConfig.baseUrl', () {
      const user = AuthUser(
        id: '1',
        email: 'x@y.com',
        profilePictureUrl: '/avatar.jpg',
      );

      final expectedUrl = Uri.parse(
        AppConfig.baseUrl,
      ).resolve('/avatar.jpg').toString();

      expect(user.resolvedProfilePictureUrl, expectedUrl);
    });

    test('returns URL unchanged on non-Android platforms', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      const user = AuthUser(
        id: '1',
        email: 'x@y.com',
        profilePictureUrl: 'http://localhost:8080/avatar.jpg',
      );

      // On iOS, localhost must not be rewritten.
      expect(
        user.resolvedProfilePictureUrl,
        'http://localhost:8080/avatar.jpg',
      );
    });

    test('returns URL unchanged when localhost not present', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      const user = AuthUser(
        id: '1',
        email: 'x@y.com',
        profilePictureUrl: 'https://cdn.example.com/avatar.jpg',
      );

      expect(
        user.resolvedProfilePictureUrl,
        'https://cdn.example.com/avatar.jpg',
      );
    });

    test('rewrites localhost to 10.0.2.2 on Android emulator', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      const user = AuthUser(
        id: '1',
        email: 'x@y.com',
        profilePictureUrl: 'http://localhost:8080/avatar.jpg',
      );

      expect(
        user.resolvedProfilePictureUrl,
        'http://10.0.2.2:8080/avatar.jpg',
      );
    });
  });
}
