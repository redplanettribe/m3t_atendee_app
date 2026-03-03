import 'package:domain/domain.dart' show AuthUser;
import 'package:m3t_api/m3t_api.dart';

extension LoginResponseMapper on LoginResponse {
  AuthUser toDomain() => AuthUser(
    id: user.id,
    email: user.email,
    name: user.name,
    lastName: user.lastName,
    createdAt: user.createdAt != null
        ? DateTime.tryParse(user.createdAt!)
        : null,
    updatedAt: user.updatedAt != null
        ? DateTime.tryParse(user.updatedAt!)
        : null,
    profilePictureUrl: user.profilePictureUrl,
  );
}
