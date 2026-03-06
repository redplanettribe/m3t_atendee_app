import 'package:equatable/equatable.dart';

/// Domain entity for a user's registration to an event.
final class EventRegistrationEntity extends Equatable {
  const EventRegistrationEntity({
    required this.id,
    required this.eventId,
  });

  final String id;
  final String eventId;

  @override
  List<Object?> get props => [id, eventId];
}
