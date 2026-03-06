import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class Event extends Equatable {
  const Event({
    required this.id,
    required this.name,
    this.startDate,
    this.durationDays,
    this.description,
    this.eventCode,
    this.locationLat,
    this.locationLng,
    this.ownerId,
    this.thumbnailUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  final String id;
  final String name;
  final String? startDate;
  final int? durationDays;
  final String? description;
  final String? eventCode;
  final double? locationLat;
  final double? locationLng;
  final String? ownerId;
  final String? thumbnailUrl;
  final String? createdAt;
  final String? updatedAt;

  Event copyWith({
    String? id,
    String? name,
    String? startDate,
    int? durationDays,
    String? description,
    String? eventCode,
    double? locationLat,
    double? locationLng,
    String? ownerId,
    String? thumbnailUrl,
    String? createdAt,
    String? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      durationDays: durationDays ?? this.durationDays,
      description: description ?? this.description,
      eventCode: eventCode ?? this.eventCode,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      ownerId: ownerId ?? this.ownerId,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => _$EventToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        startDate,
        durationDays,
        description,
        eventCode,
        locationLat,
        locationLng,
        ownerId,
        thumbnailUrl,
        createdAt,
        updatedAt,
      ];
}
