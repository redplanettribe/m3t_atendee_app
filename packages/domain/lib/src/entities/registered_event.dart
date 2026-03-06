import 'package:equatable/equatable.dart';

/// Domain entity for an event the current user is registered for (list item).
final class RegisteredEventEntity extends Equatable {
  const RegisteredEventEntity({
    required this.eventId,
    required this.name,
    required this.registrationId,
    this.description,
    this.eventCode,
    this.date,
  });

  final String eventId;
  final String name;
  final String? description;
  final String? eventCode;
  final String? date;
  final String registrationId;

  @override
  List<Object?> get props =>
      [eventId, name, description, eventCode, date, registrationId];
}
