import 'package:attendee_repository/src/local/registered_event_hive_model.dart';
import 'package:attendee_repository/src/local/registered_events_local_data_source.dart';
import 'package:domain/domain.dart';
import 'package:hive/hive.dart';

final class HiveRegisteredEventsDataSource
    implements RegisteredEventsLocalDataSource {
  HiveRegisteredEventsDataSource({required Box<RegisteredEventHiveModel> box})
    : _box = box;

  // Used by bootstrap.dart to open the correct box — single source of truth
  // for the box name string.
  static const String boxName = 'registered_events';

  final Box<RegisteredEventHiveModel> _box;

  @override
  List<RegisteredEventEntity> read() =>
      _box.values.map((model) => model.toEntity()).toList();

  @override
  Future<void> write(List<RegisteredEventEntity> events) async {
    await _box.clear();
    await _box.addAll(events.map(RegisteredEventHiveModel.fromEntity));
  }

  @override
  Future<void> clear() => _box.clear();
}
