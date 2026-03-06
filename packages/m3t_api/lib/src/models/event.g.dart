// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
  id: json['id'] as String,
  name: json['name'] as String,
  startDate: json['start_date'] as String?,
  durationDays: (json['duration_days'] as int?),
  description: json['description'] as String?,
  eventCode: json['event_code'] as String?,
  locationLat: (json['location_lat'] as num?)?.toDouble(),
  locationLng: (json['location_lng'] as num?)?.toDouble(),
  ownerId: json['owner_id'] as String?,
  thumbnailUrl: json['thumbnail_url'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'start_date': instance.startDate,
  'duration_days': instance.durationDays,
  'description': instance.description,
  'event_code': instance.eventCode,
  'location_lat': instance.locationLat,
  'location_lng': instance.locationLng,
  'owner_id': instance.ownerId,
  'thumbnail_url': instance.thumbnailUrl,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
