import 'package:equatable/equatable.dart';

final class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.email,
    this.name,
    this.lastName,
    this.createdAt,
    this.updatedAt,
    this.profilePictureUrl,
  });

  final String id;
  final String email;
  final String? name;
  final String? lastName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? profilePictureUrl;

  AuthUser copyWith({
    String? id,
    String? email,
    Object? name = _sentinel,
    Object? lastName = _sentinel,
    Object? createdAt = _sentinel,
    Object? updatedAt = _sentinel,
    Object? profilePictureUrl = _sentinel,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name == _sentinel ? this.name : name as String?,
      lastName: lastName == _sentinel ? this.lastName : lastName as String?,
      createdAt: createdAt == _sentinel
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: updatedAt == _sentinel
          ? this.updatedAt
          : updatedAt as DateTime?,
      profilePictureUrl: profilePictureUrl == _sentinel
          ? this.profilePictureUrl
          : profilePictureUrl as String?,
    );
  }

  static const _sentinel = Object();

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    lastName,
    createdAt,
    updatedAt,
    profilePictureUrl,
  ];
}
