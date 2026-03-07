import 'package:attendee_repository/src/local/registered_events_local_data_source.dart';
import 'package:attendee_repository/src/mappers/event_registration_mapper.dart';
import 'package:attendee_repository/src/mappers/registered_event_item_mapper.dart';
import 'package:domain/domain.dart';
import 'package:m3t_api/m3t_api.dart' as m3t;

final class AttendeeRepositoryImpl implements AttendeeRepository {
  AttendeeRepositoryImpl({
    required m3t.M3tApiClient apiClient,
    required RegisteredEventsLocalDataSource localDataSource,
  }) : _apiClient = apiClient,
       _localDataSource = localDataSource;

  final m3t.M3tApiClient _apiClient;
  final RegisteredEventsLocalDataSource _localDataSource;

  @override
  Future<EventRegistrationEntity> registerForEventByCode(
    String eventCode,
  ) async {
    try {
      final registration = await _apiClient.registerForEventByCode(eventCode);
      return registration.toDomain();
    } on m3t.RegisterForEventByCodeFailure catch (e) {
      if (e.statusCode == 404 || e.errorCode == 'not_found') {
        throw const EventNotFound();
      }
      // 400: server-side validation failure — distinct from client-side
      // InvalidEventCode (format guard), which is never reached here because
      // the cubit and formatter already enforce the 4-char alphanumeric rule.
      if (e.statusCode == 400 || e.errorCode == 'bad_request') {
        throw const RegistrationBadRequest();
      }
      // 401: auth failure — not a network error; maps to unknown until a
      // dedicated RegistrationUnauthorized domain type is added.
      if (e.statusCode == 401 || e.errorCode == 'unauthorized') {
        throw const RegistrationUnknownError();
      }
      throw const RegistrationUnknownError();
    } on Exception catch (_) {
      throw const RegistrationNetworkError();
    }
  }

  @override
  Future<List<RegisteredEventEntity>> getMyRegisteredEvents({
    String? status,
    int? page,
    int? pageSize,
  }) async {
    try {
      final response = await _apiClient.getMyRegisteredEvents(
        status: status,
        page: page,
        pageSize: pageSize,
      );

      final entities = response.items.map((item) => item.toDomain()).toList();
      await _localDataSource.write(entities);
      return entities;
    } on m3t.GetMyRegisteredEventsFailure catch (e) {
      if (e.statusCode == 401 || e.errorCode == 'unauthorized') {
        throw GetMyRegisteredEventsUnauthorized();
      }
      if (e.statusCode != null && e.statusCode! >= 500) {
        throw GetMyRegisteredEventsUnknown();
      }
      throw GetMyRegisteredEventsNetworkError();
    } on FormatException catch (e, stackTrace) {
      // start_date missing or malformed — server contract violation, not a
      // network error. Surface as unknown so the cubit emits a failure state
      // rather than silently swallowing a bad payload.
      Error.throwWithStackTrace(GetMyRegisteredEventsUnknown(), stackTrace);
    } on Exception catch (_) {
      throw GetMyRegisteredEventsNetworkError();
    }
  }

  @override
  List<RegisteredEventEntity> getCachedRegisteredEvents() =>
      _localDataSource.read();

  @override
  Future<void> clearCache() => _localDataSource.clear();
}
