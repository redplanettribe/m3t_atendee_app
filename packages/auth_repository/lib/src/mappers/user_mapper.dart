import 'package:domain/domain.dart' show AuthUser;
import 'package:m3t_api/m3t_api.dart';

extension UserMapper on User {
  AuthUser toDomain() => AuthUser(
    id: id,
    email: email,
    name: name,
    lastName: lastName,
    createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
    profilePictureUrl: profilePictureUrl,
  );
}
