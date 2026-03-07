import 'package:auth_repository/src/mappers/user_mapper.dart';
import 'package:domain/domain.dart' show AuthUser;
import 'package:m3t_api/m3t_api.dart';

extension LoginResponseMapper on LoginResponse {
  AuthUser toDomain() => user.toDomain();
}
