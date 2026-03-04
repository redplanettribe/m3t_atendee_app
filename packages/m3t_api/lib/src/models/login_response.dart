import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:m3t_api/src/models/user.dart';

part 'login_response.g.dart';

@JsonSerializable(fieldRename: .snake)
final class LoginResponse extends Equatable {
  const LoginResponse({
    required this.token,
    required this.tokenType,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

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

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  @override
  List<Object?> get props => [token, tokenType, user];
}
