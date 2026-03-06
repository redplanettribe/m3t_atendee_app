// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_my_registered_events_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListMyRegisteredEventsItem _$ListMyRegisteredEventsItemFromJson(
  Map<String, dynamic> json,
) => ListMyRegisteredEventsItem(
  event: Event.fromJson(json['event'] as Map<String, dynamic>),
  registration: EventRegistration.fromJson(
    json['registration'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ListMyRegisteredEventsItemToJson(
  ListMyRegisteredEventsItem instance,
) => <String, dynamic>{
  'event': instance.event,
  'registration': instance.registration,
};
