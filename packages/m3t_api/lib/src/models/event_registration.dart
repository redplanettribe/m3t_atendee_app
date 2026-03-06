import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_registration.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class EventRegistration extends Equatable {
  const EventRegistration({
    required this.id,
    required this.eventId,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory EventRegistration.fromJson(Map<String, dynamic> json) =>
      _$EventRegistrationFromJson(json);

  final String id;
  final String eventId;
  final String userId;
  final String? createdAt;
  final String? updatedAt;

  EventRegistration copyWith({
    String? id,
    String? eventId,
    String? userId,
    String? createdAt,
    String? updatedAt,
  }) {
    return EventRegistration(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => _$EventRegistrationToJson(this);

  @override
  List<Object?> get props => [id, eventId, userId, createdAt, updatedAt];
}
