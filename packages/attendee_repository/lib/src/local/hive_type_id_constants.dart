/// Centralised registry of Hive `typeId` values used across the
/// `attendee_repository` local storage layer.
///
/// Each constant maps a `HiveType`-annotated model class to a unique,
/// **stable** integer identifier. Hive uses these IDs to serialise and
/// deserialise objects — changing or reusing a value for a different type
/// is a **breaking change** that corrupts existing on-device data.
///
/// ### Rules
/// - Never change an existing value.
/// - Never reuse a deleted value.
/// - Always add new entries at the end with the next sequential integer.
abstract final class HiveTypeIdConstants {
  /// `RegisteredEventHiveModel` — stores a single registered-event list item.
  static const int registeredEventModel = 0;
}
