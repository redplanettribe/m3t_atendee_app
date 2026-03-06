import 'package:domain/domain.dart';
import 'package:m3t_api/m3t_api.dart' as m3t;

final class AttendeeRepositoryImpl implements AttendeeRepository {
  AttendeeRepositoryImpl({required m3t.M3tApiClient apiClient})
      : _apiClient = apiClient;

  final m3t.M3tApiClient _apiClient;

  @override
  Future<EventRegistrationEntity> registerForEventByCode(
    String eventCode,
  ) async {
    try {
      final registration = await _apiClient.registerForEventByCode(eventCode);
      return EventRegistrationEntity(
        id: registration.id,
        eventId: registration.eventId,
      );
    } on m3t.RegisterForEventByCodeFailure catch (e) {
      if (e.statusCode == 404 || e.errorCode == 'not_found') {
        throw EventNotFound();
      }
      if (e.statusCode == 400 || e.errorCode == 'bad_request') {
        throw InvalidEventCode();
      }
      if (e.statusCode == 401 || e.errorCode == 'unauthorized') {
        throw RegistrationNetworkError();
      }
      throw RegistrationUnknownError();
    } on Exception catch (_) {
      throw RegistrationNetworkError();
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
      return response.items
          .map(
            (item) => RegisteredEventEntity(
              eventId: item.event.id,
              name: item.event.name,
              registrationId: item.registration.id,
              description: item.event.description,
              eventCode: item.event.eventCode,
              date: item.event.date,
            ),
          )
          .toList();
    } on m3t.GetMyRegisteredEventsFailure catch (e) {
      if (e.statusCode == 401 || e.errorCode == 'unauthorized') {
        throw GetMyRegisteredEventsUnauthorized();
      }
      if (e.statusCode != null && e.statusCode! >= 500) {
        throw GetMyRegisteredEventsUnknown();
      }
      throw GetMyRegisteredEventsNetworkError();
    } on Exception catch (_) {
      throw GetMyRegisteredEventsNetworkError();
    }
  }
}
