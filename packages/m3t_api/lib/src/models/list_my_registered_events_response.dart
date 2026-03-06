import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:m3t_api/src/models/list_my_registered_events_item.dart';
import 'package:m3t_api/src/models/pagination_meta.dart';

part 'list_my_registered_events_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class ListMyRegisteredEventsResponse extends Equatable {
  const ListMyRegisteredEventsResponse({
    this.items = const [],
    this.pagination,
  });

  factory ListMyRegisteredEventsResponse.fromJson(Map<String, dynamic> json) =>
      _$ListMyRegisteredEventsResponseFromJson(json);

  final List<ListMyRegisteredEventsItem> items;
  final PaginationMeta? pagination;

  ListMyRegisteredEventsResponse copyWith({
    List<ListMyRegisteredEventsItem>? items,
    PaginationMeta? pagination,
  }) {
    return ListMyRegisteredEventsResponse(
      items: items ?? this.items,
      pagination: pagination ?? this.pagination,
    );
  }

  Map<String, dynamic> toJson() => _$ListMyRegisteredEventsResponseToJson(this);

  @override
  List<Object?> get props => [items, pagination];
}
