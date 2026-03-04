import 'dart:async';

import 'package:auth_repository/src/mappers/login_response_mapper.dart';
import 'package:auth_repository/src/mappers/user_mapper.dart';
import 'package:auth_repository/src/ports/token_storage.dart';
import 'package:domain/domain.dart';
import 'package:m3t_api/m3t_api.dart';

final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required M3tApiClient apiClient,
    required TokenStorage tokenStorage,
  }) : _apiClient = apiClient,
       _tokenStorage = tokenStorage;

  final M3tApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthStatus _currentStatus = AuthStatus.unknown;
  final _statusController = StreamController<AuthStatus>.broadcast();
  AuthUser? _currentUser;

  /// Stream of [AuthStatus] changes.
  @override
  Stream<AuthStatus> get status => _statusController.stream;

  @override
  AuthStatus get currentStatus => _currentStatus;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Future<void> initialize() async {
    try {
      final token = await _tokenStorage.read();
      _currentStatus = token != null ? .authenticated : .unauthenticated;
    } on Exception catch (_) {
      _currentStatus = .unauthenticated;
    }
    _emitStatus(_currentStatus);
  }

  /// Sends a one-time login code to the given [email].
  @override
  Future<void> requestLoginCode(String email) async {
    try {
      await _apiClient.requestLoginCode(email);
    } on RequestLoginCodeFailure catch (_) {
      throw NetworkError();
    } on Exception catch (_) {
      throw UnknownError();
    }
  }

  /// Verifies the one-time [code] for [email] and persists the token.
  @override
  Future<AuthUser> verifyLoginCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _apiClient.verifyLoginCode(
        email: email,
        code: code,
      );

      final user = response.toDomain();
      _currentUser = user;

      await _tokenStorage.write(response.token);
      _emitStatus(.authenticated);

      return user;
    } on VerifyLoginCodeFailure catch (_) {
      throw InvalidCode();
    } on Exception catch (_) {
      throw UnknownError();
    }
  }

  // ---------------------------------------------------------------------------
  // ---------------------------------------------------------------------------
  // User profile
  // ---------------------------------------------------------------------------

  /// Fetches the authenticated user's profile.
  @override
  Future<AuthUser> getCurrentUser() async {
    try {
      return (await _apiClient.getCurrentUser()).toDomain();
    } on GetCurrentUserFailure catch (_) {
      throw NetworkError();
    } on Exception catch (_) {
      throw UnknownError();
    }
  }

  /// Updates the authenticated user's profile.
  ///
  /// At least one of [name] or [lastName] must be provided.
  @override
  Future<AuthUser> updateCurrentUser({
    String? name,
    String? lastName,
  }) async {
    try {
      final result = await _apiClient.updateCurrentUser(
        name: name,
        lastName: lastName,
      );
      return result.toDomain();
    } on UpdateCurrentUserFailure catch (_) {
      throw NetworkError();
    } on Exception catch (_) {
      throw UnknownError();
    }
  }

  /// Requests a presigned S3 upload URL and object key for the user's avatar.
  @override
  Future<(Uri uploadUrl, String key)> requestAvatarUpload() async {
    try {
      return await _apiClient.requestAvatarUploadUrl();
    } on RequestAvatarUploadFailure catch (_) {
      throw NetworkError();
    } on Exception catch (_) {
      throw UnknownError();
    }
  }

  /// Uploads avatar [bytes] directly to [uploadUrl].
  @override
  Future<void> uploadAvatar({
    required Uri uploadUrl,
    required List<int> bytes,
    required String contentType,
  }) async {
    try {
      await _apiClient.uploadAvatarBytes(
        uploadUrl: uploadUrl,
        bytes: bytes,
        contentType: contentType,
      );
    } on UploadAvatarFailure catch (_) {
      throw NetworkError();
    } on Exception catch (_) {
      throw UnknownError();
    }
  }

  /// Confirms the uploaded avatar with the backend and
  /// returns the updated user.
  @override
  Future<AuthUser> confirmAvatar({required String key}) async {
    try {
      return (await _apiClient.confirmAvatar(key: key)).toDomain();
    } on ConfirmAvatarFailure catch (_) {
      throw NetworkError();
    } on Exception catch (_) {
      throw UnknownError();
    }
  }

  // ---------------------------------------------------------------------------
  // Auth lifecycle
  // ---------------------------------------------------------------------------

  /// Deletes the stored token and emits [AuthStatus.unauthenticated].
  @override
  Future<void> logout() async {
    _currentUser = null;
    await _tokenStorage.delete();
    _emitStatus(.unauthenticated);
  }

  /// Closes the internal stream controller.
  @override
  Future<void> dispose() async {
    await _statusController.close();
  }

  void _emitStatus(AuthStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }
}
