import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:m3t_api/m3t_api.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthRepository {
  AuthRepository({
    required M3tApiClient apiClient,
    FlutterSecureStorage? secureStorage,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final M3tApiClient _apiClient;
  final FlutterSecureStorage _secureStorage;

  static const tokenKey = 'auth_token';

  final _statusController = StreamController<AuthStatus>.broadcast();

  /// Stream of [AuthStatus] changes.
  Stream<AuthStatus> get status async* {
    final token = await getToken();
    yield token != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    yield* _statusController.stream;
  }

  /// Sends a one-time login code to the given [email].
  Future<void> requestLoginCode(String email) async {
    await _apiClient.requestLoginCode(email);
  }

  /// Verifies the one-time [code] for [email] and persists the token.
  ///
  /// Returns the [LoginResponse] containing the JWT and user.
  Future<LoginResponse> verifyLoginCode({
    required String email,
    required String code,
  }) async {
    final response = await _apiClient.verifyLoginCode(
      email: email,
      code: code,
    );
    await _secureStorage.write(key: tokenKey, value: response.token);
    _statusController.add(AuthStatus.authenticated);
    return response;
  }

  /// Returns the persisted JWT, or `null` if none is stored.
  Future<String?> getToken() => _secureStorage.read(key: tokenKey);

  /// Deletes the stored token and emits [AuthStatus.unauthenticated].
  Future<void> logout() async {
    await _secureStorage.delete(key: tokenKey);
    _statusController.add(AuthStatus.unauthenticated);
  }

  /// Closes the internal stream controller. Call when the repository
  /// is no longer needed.
  void dispose() {
    _statusController.close();
  }
}
