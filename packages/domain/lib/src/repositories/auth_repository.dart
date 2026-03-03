import 'package:domain/src/entities/auth_user.dart';
import 'package:domain/src/enums/auth_status.dart';

abstract interface class AuthRepository {
  Stream<AuthStatus> get status;
  AuthStatus get currentStatus;
  AuthUser? get currentUser;

  Future<void> initialize();
  Future<void> requestLoginCode(String email);
  Future<AuthUser> verifyLoginCode({
    required String email,
    required String code,
  });

  /// Fetches the authenticated user's profile.
  Future<AuthUser> getCurrentUser();

  /// Updates the authenticated user's profile.
  ///
  /// At least one of [name] or [lastName] must be provided.
  Future<AuthUser> updateCurrentUser({
    String? name,
    String? lastName,
  });

  /// Requests a presigned S3 upload URL and object key for the user's avatar.
  Future<(Uri uploadUrl, String key)> requestAvatarUpload();

  /// Uploads avatar [bytes] directly to [uploadUrl].
  Future<void> uploadAvatar({
    required Uri uploadUrl,
    required List<int> bytes,
    required String contentType,
  });

  /// Confirms the uploaded avatar with the backend and
  /// returns the updated user.
  Future<AuthUser> confirmAvatar({required String key});

  Future<void> logout();
  Future<void> dispose();
}
