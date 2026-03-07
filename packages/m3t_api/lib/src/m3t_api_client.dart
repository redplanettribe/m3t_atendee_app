import 'package:http/http.dart' as http;
import 'package:m3t_api/src/data_sources/attendee_data_source.dart';
import 'package:m3t_api/src/data_sources/auth_data_source.dart';
import 'package:m3t_api/src/data_sources/user_data_source.dart';
import 'package:m3t_api/src/http/api_http_executor.dart';
import 'package:m3t_api/src/models/event_registration.dart';
import 'package:m3t_api/src/models/list_my_registered_events_response.dart';
import 'package:m3t_api/src/models/login_response.dart';
import 'package:m3t_api/src/models/user.dart';

/// Signature for a callback that returns the stored auth token (or null).
typedef TokenProvider = Future<String?> Function();

/// Facade that delegates every API call to a typed per-domain data source.
///
/// Call sites are unchanged — all method signatures are preserved exactly.
/// Infrastructure (HTTP client, base URL, token provider) is shared via
/// [ApiHttpExecutor] and injected into each data source at construction time.
class M3tApiClient {
  M3tApiClient({
    http.Client? httpClient,
    String? baseUrl,
    Uri? objectStoreBaseUrl,
    TokenProvider? tokenProvider,
  }) {
    final executor = ApiHttpExecutor(
      httpClient: httpClient ?? http.Client(),
      baseUrl: baseUrl ?? 'http://10.0.2.2:8080',
      objectStoreBaseUrl: objectStoreBaseUrl,
      tokenProvider: tokenProvider,
    );
    _auth = AuthDataSource(executor: executor);
    _user = UserDataSource(executor: executor);
    _attendee = AttendeeDataSource(executor: executor);
  }

  late final AuthDataSource _auth;
  late final UserDataSource _user;
  late final AttendeeDataSource _attendee;

  // ── Auth ─────────────────────────────────────────────────────────────────

  Future<void> requestLoginCode(String email) => _auth.requestLoginCode(email);

  Future<LoginResponse> verifyLoginCode({
    required String email,
    required String code,
  }) => _auth.verifyLoginCode(email: email, code: code);

  // ── User ─────────────────────────────────────────────────────────────────

  Future<User> getCurrentUser() => _user.getCurrentUser();

  Future<User> updateCurrentUser({String? name, String? lastName}) =>
      _user.updateCurrentUser(name: name, lastName: lastName);

  Future<(Uri uploadUrl, String key)> requestAvatarUploadUrl() =>
      _user.requestAvatarUploadUrl();

  Future<void> uploadAvatarBytes({
    required Uri uploadUrl,
    required List<int> bytes,
    required String contentType,
  }) => _user.uploadAvatarBytes(
    uploadUrl: uploadUrl,
    bytes: bytes,
    contentType: contentType,
  );

  Future<User> confirmAvatar({required String key}) =>
      _user.confirmAvatar(key: key);

  // ── Attendee ─────────────────────────────────────────────────────────────

  Future<EventRegistration> registerForEventByCode(String eventCode) =>
      _attendee.registerForEventByCode(eventCode);

  Future<ListMyRegisteredEventsResponse> getMyRegisteredEvents({
    String? status,
    int? page,
    int? pageSize,
  }) => _attendee.getMyRegisteredEvents(
    status: status,
    page: page,
    pageSize: pageSize,
  );
}
