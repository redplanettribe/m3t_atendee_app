import 'dart:convert';

import 'package:m3t_api/src/exceptions.dart';
import 'package:m3t_api/src/http/api_http_executor.dart';
import 'package:m3t_api/src/models/api_error.dart';
import 'package:m3t_api/src/models/event_registration.dart';
import 'package:m3t_api/src/models/event_schedule/event_schedule.dart';
import 'package:m3t_api/src/models/list_my_registered_events_response.dart';

/// Handles all attendee-scoped API calls: registrations and event schedules.
final class AttendeeDataSource {
  const AttendeeDataSource({required ApiHttpExecutor executor})
    : _executor = executor;

  final ApiHttpExecutor _executor;

  /// Registers the authenticated user for the event identified by [eventCode]
  /// (4 characters). Idempotent: returns 200 if already registered, 201 if new.
  Future<EventRegistration> registerForEventByCode(String eventCode) async {
    final response = await _executor.client.post(
      _executor.uri('/attendee/registrations'),
      headers: await _executor.authHeaders(),
      body: jsonEncode(<String, String>{'event_code': eventCode}),
    );

    final body = _executor.decodeJson(response.body);
    final errorJson = body['error'] as Map<String, dynamic>?;
    final apiError = errorJson != null ? ApiError.fromJson(errorJson) : null;

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw RegisterForEventByCodeFailure(
        apiError?.message ??
            'Request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
        errorCode: apiError?.code,
      );
    }
    if (apiError != null) {
      throw RegisterForEventByCodeFailure(
        apiError.message,
        errorCode: apiError.code,
      );
    }

    final dataJson = body['data'] as Map<String, dynamic>?;
    if (dataJson == null) {
      throw RegisterForEventByCodeFailure('Missing data field in response');
    }

    return EventRegistration.fromJson(dataJson);
  }

  /// Returns the list of events the authenticated user is registered for.
  ///
  /// Optional [status]: `active`, `past`, or `all` (default all).
  /// Optional [page] and [pageSize] for pagination.
  Future<ListMyRegisteredEventsResponse> getMyRegisteredEvents({
    String? status,
    int? page,
    int? pageSize,
  }) async {
    final query = <String, String>{};
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (page != null) query['page'] = page.toString();
    if (pageSize != null) query['page_size'] = pageSize.toString();

    final uri = query.isEmpty
        ? _executor.uri('/attendee/events')
        : _executor.uri('/attendee/events').replace(queryParameters: query);

    final response = await _executor.client.get(
      uri,
      headers: await _executor.authHeaders(),
    );

    if (response.statusCode != 200) {
      final body = _executor.decodeJson(response.body);
      final errorJson = body['error'] as Map<String, dynamic>?;
      final apiError = errorJson != null ? ApiError.fromJson(errorJson) : null;
      throw GetMyRegisteredEventsFailure(
        apiError?.message ??
            'Request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
        errorCode: apiError?.code,
      );
    }

    final body = _executor.decodeJson(response.body);
    final errorJson = body['error'] as Map<String, dynamic>?;
    if (errorJson != null) {
      final error = ApiError.fromJson(errorJson);
      throw GetMyRegisteredEventsFailure(
        error.message,
        errorCode: error.code,
      );
    }

    final dataJson = body['data'] as Map<String, dynamic>?;
    if (dataJson == null) {
      throw GetMyRegisteredEventsFailure('Missing data field in response');
    }

    return ListMyRegisteredEventsResponse.fromJson(dataJson);
  }

  Future<EventSchedule> getEventById(String eventId) async {
    final response = await _executor.client.get(
      _executor.uri('/attendee/events/$eventId/schedule'),
      headers: await _executor.authHeaders(),
    );

    if (response.statusCode != 200) {
      throw GetEventByIdFailure(
        'Request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    final body = _executor.decodeJson(response.body);
    final errorJson = body['error'] as Map<String, dynamic>?;
    if (errorJson != null) {
      final error = ApiError.fromJson(errorJson);
      throw GetEventByIdFailure(
        error.message,
        errorCode: error.code,
      );
    }

    final dataJson = body['data'] as Map<String, dynamic>?;
    if (dataJson == null) {
      throw GetEventByIdFailure('Missing data field in response');
    }

    return EventSchedule.fromJson(dataJson);
  }
}
