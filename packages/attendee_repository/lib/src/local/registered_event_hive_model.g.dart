// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registered_event_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RegisteredEventHiveModelAdapter
    extends TypeAdapter<RegisteredEventHiveModel> {
  @override
  final int typeId = 0;

  @override
  RegisteredEventHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RegisteredEventHiveModel(
      eventId: fields[0] as String,
      name: fields[1] as String,
      registrationId: fields[2] as String,
      startDate: fields[5] as DateTime,
      description: fields[3] as String?,
      eventCode: fields[4] as String?,
      durationDays: fields[6] as int?,
      thumbnailUrl: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RegisteredEventHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.eventId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.registrationId)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.eventCode)
      ..writeByte(5)
      ..write(obj.startDate)
      ..writeByte(6)
      ..write(obj.durationDays)
      ..writeByte(7)
      ..write(obj.thumbnailUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisteredEventHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
