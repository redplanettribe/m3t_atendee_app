import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(fieldRename: .snake)
final class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    this.name,
    this.lastName,
    this.createdAt,
    this.updatedAt,
    this.profilePictureUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  final String id;
  final String email;
  final String? name;
  final String? lastName;
  final String? createdAt;
  final String? updatedAt;
   final String? profilePictureUrl;

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? lastName,
    String? createdAt,
    String? updatedAt,
    String? profilePictureUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props =>
      [id, email, name, lastName, createdAt, updatedAt, profilePictureUrl];
}
