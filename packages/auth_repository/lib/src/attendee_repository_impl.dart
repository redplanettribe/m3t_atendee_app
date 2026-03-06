import 'package:domain/domain.dart';
import 'package:m3t_api/m3t_api.dart';

final class AttendeeRepositoryImpl implements AttendeeRepository {
  AttendeeRepositoryImpl({required M3tApiClient apiClient}) : _apiClient = apiClient;

  final M3tApiClient _apiClient;

  @override
  Future<EventRegistrationEntity> registerForEventByCode(String eventCode) async {
    try {
      final registration = await _apiClient.registerForEventByCode(eventCode);
      return EventRegistrationEntity(
        id: registration.id,
        eventId: registration.eventId,
      );
    } on RegisterForEventByCodeFailure catch (e) {
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
}
