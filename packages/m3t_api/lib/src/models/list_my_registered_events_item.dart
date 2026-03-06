import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:m3t_api/src/models/event.dart';
import 'package:m3t_api/src/models/event_registration.dart';

part 'list_my_registered_events_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class ListMyRegisteredEventsItem extends Equatable {
  const ListMyRegisteredEventsItem({
    required this.event,
    required this.registration,
  });

  factory ListMyRegisteredEventsItem.fromJson(Map<String, dynamic> json) =>
      _$ListMyRegisteredEventsItemFromJson(json);

  final Event event;
  final EventRegistration registration;

  ListMyRegisteredEventsItem copyWith({
    Event? event,
    EventRegistration? registration,
  }) {
    return ListMyRegisteredEventsItem(
      event: event ?? this.event,
      registration: registration ?? this.registration,
    );
  }

  Map<String, dynamic> toJson() => _$ListMyRegisteredEventsItemToJson(this);

  @override
  List<Object?> get props => [event, registration];
}
