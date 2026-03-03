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

  /// Fetches the authenticated user's profile using the stored token.
  Future<User> getCurrentUser() {
    return _apiClient.getCurrentUser();
  }

  /// Updates the authenticated user's profile.
  ///
  /// At least one of [name] or [lastName] must be provided.
  Future<User> updateCurrentUser({
    String? name,
    String? lastName,
  }) {
    return _apiClient.updateCurrentUser(name: name, lastName: lastName);
  }

  /// Requests a presigned upload URL and object key for the user's avatar.
  ///
  /// Returns a record containing the [uploadUrl] and storage [key].
  Future<(Uri uploadUrl, String key)> requestAvatarUpload() {
    return _apiClient.requestAvatarUploadUrl();
  }

  /// Uploads avatar bytes directly to the provided [uploadUrl].
  Future<void> uploadAvatar({
    required Uri uploadUrl,
    required List<int> bytes,
    required String contentType,
  }) {
    print('uploadUrl: $uploadUrl');
    return _apiClient.uploadAvatarBytes(
      uploadUrl: uploadUrl,
      bytes: bytes,
      contentType: contentType,
    );
  }

  /// Confirms the uploaded avatar with the backend and returns the updated user.
  Future<User> confirmAvatar({required String key}) {
    return _apiClient.confirmAvatar(key: key);
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
