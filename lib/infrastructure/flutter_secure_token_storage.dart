import 'package:auth_repository/auth_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// [TokenStorage] adapter backed by [FlutterSecureStorage].
final class FlutterSecureTokenStorage implements TokenStorage {
  const FlutterSecureTokenStorage({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _tokenKey);

  @override
  Future<void> write(String token) =>
      _storage.write(key: _tokenKey, value: token);

  @override
  Future<void> delete() => _storage.delete(key: _tokenKey);
}
