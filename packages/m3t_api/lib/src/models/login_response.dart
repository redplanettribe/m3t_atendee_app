import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'user.dart';

part 'login_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LoginResponse extends Equatable {
  const LoginResponse({
    required this.token,
    required this.tokenType,
    required this.user,
  });

  final String token;
  final String tokenType;
  final User user;

  LoginResponse copyWith({
    String? token,
    String? tokenType,
    User? user,
  }) {
    return LoginResponse(
      token: token ?? this.token,
      tokenType: tokenType ?? this.tokenType,
      user: user ?? this.user,
    );
  }

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  @override
  List<Object?> get props => [token, tokenType, user];
}

