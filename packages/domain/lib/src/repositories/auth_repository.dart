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
  Future<void> logout();
  Future<void> dispose();
}
