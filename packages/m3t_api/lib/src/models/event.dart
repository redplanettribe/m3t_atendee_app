import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class Event extends Equatable {
  const Event({
    required this.id,
    required this.name,
    this.date,
    this.description,
    this.eventCode,
    this.locationLat,
    this.locationLng,
    this.ownerId,
    this.createdAt,
    this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  final String id;
  final String name;
  final String? date;
  final String? description;
  final String? eventCode;
  final double? locationLat;
  final double? locationLng;
  final String? ownerId;
  final String? createdAt;
  final String? updatedAt;

  Event copyWith({
    String? id,
    String? name,
    String? date,
    String? description,
    String? eventCode,
    double? locationLat,
    double? locationLng,
    String? ownerId,
    String? createdAt,
    String? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      description: description ?? this.description,
      eventCode: eventCode ?? this.eventCode,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => _$EventToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        date,
        description,
        eventCode,
        locationLat,
        locationLng,
        ownerId,
        createdAt,
        updatedAt,
      ];
}
