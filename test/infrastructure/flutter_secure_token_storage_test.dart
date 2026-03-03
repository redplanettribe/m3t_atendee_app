import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_attendee/infrastructure/flutter_secure_token_storage.dart';
import 'package:mocktail/mocktail.dart';

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  group('FlutterSecureTokenStorage', () {
    late _MockFlutterSecureStorage storage;
    late FlutterSecureTokenStorage tokenStorage;

    const tokenKey = 'auth_token';
    const testToken = 'jwt.token.value';

    setUp(() {
      storage = _MockFlutterSecureStorage();
      tokenStorage = FlutterSecureTokenStorage(storage: storage);
    });

    group('read()', () {
      test('delegates to FlutterSecureStorage with the correct key', () async {
        when(
          () => storage.read(key: tokenKey),
        ).thenAnswer((_) async => testToken);

        final result = await tokenStorage.read();

        expect(result, equals(testToken));
        verify(() => storage.read(key: tokenKey)).called(1);
      });

      test('returns null when no token is stored', () async {
        when(
          () => storage.read(key: tokenKey),
        ).thenAnswer((_) async => null);

        final result = await tokenStorage.read();

        expect(result, isNull);
      });
    });

    group('write()', () {
      test(
        'delegates to FlutterSecureStorage with the correct key and value',
        () async {
          when(
            () => storage.write(key: tokenKey, value: testToken),
          ).thenAnswer((_) async {});

          await tokenStorage.write(testToken);

          verify(
            () => storage.write(key: tokenKey, value: testToken),
          ).called(1);
        },
      );
    });

    group('delete()', () {
      test('delegates to FlutterSecureStorage with the correct key', () async {
        when(
          () => storage.delete(key: tokenKey),
        ).thenAnswer((_) async {});

        await tokenStorage.delete();

        verify(() => storage.delete(key: tokenKey)).called(1);
      });
    });
  });
}
