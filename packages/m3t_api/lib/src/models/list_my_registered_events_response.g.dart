// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_my_registered_events_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListMyRegisteredEventsResponse _$ListMyRegisteredEventsResponseFromJson(
  Map<String, dynamic> json,
) => ListMyRegisteredEventsResponse(
  items:
      (json['items'] as List<dynamic>?)
          ?.map(
            (e) =>
                ListMyRegisteredEventsItem.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  pagination: json['pagination'] == null
      ? null
      : PaginationMeta.fromJson(json['pagination'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ListMyRegisteredEventsResponseToJson(
  ListMyRegisteredEventsResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'pagination': instance.pagination,
};
