import 'package:attendee_repository/src/local/hive_type_id_constants.dart';
import 'package:domain/domain.dart';
import 'package:hive/hive.dart';

part 'registered_event_hive_model.g.dart';

@HiveType(typeId: HiveTypeIdConstants.registeredEventModel)
final class RegisteredEventHiveModel extends HiveObject {
  RegisteredEventHiveModel({
    required this.eventId,
    required this.name,
    required this.registrationId,
    required this.startDate,
    this.description,
    this.eventCode,
    this.durationDays,
    this.thumbnailUrl,
  });
  factory RegisteredEventHiveModel.fromEntity(RegisteredEventEntity entity) =>
      RegisteredEventHiveModel(
        eventId: entity.eventId,
        name: entity.name,
        registrationId: entity.registrationId,
        startDate: entity.startDate,
        description: entity.description,
        eventCode: entity.eventCode,
        durationDays: entity.durationDays,
        thumbnailUrl: entity.thumbnailUrl,
      );

  @HiveField(0)
  final String eventId;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String registrationId;
  @HiveField(3)
  final String? description;
  @HiveField(4)
  final String? eventCode;
  @HiveField(5)
  final DateTime startDate;
  @HiveField(6)
  final int? durationDays;
  @HiveField(7)
  final String? thumbnailUrl;

  RegisteredEventEntity toEntity() => RegisteredEventEntity(
    eventId: eventId,
    name: name,
    registrationId: registrationId,
    startDate: startDate,
    description: description,
    eventCode: eventCode,
    durationDays: durationDays,
    thumbnailUrl: thumbnailUrl,
  );
}
