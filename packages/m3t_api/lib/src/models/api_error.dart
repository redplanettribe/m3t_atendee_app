import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api_error.g.dart';

@JsonSerializable()
class ApiError extends Equatable {
  const ApiError({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;

  ApiError copyWith({
    String? code,
    String? message,
  }) {
    return ApiError(
      code: code ?? this.code,
      message: message ?? this.message,
    );
  }

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);

  @override
  List<Object?> get props => [code, message];
}

