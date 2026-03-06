import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:m3t_api/src/exceptions.dart';
import 'package:m3t_api/src/models/api_error.dart';
import 'package:m3t_api/src/models/event_registration.dart';
import 'package:m3t_api/src/models/login_response.dart';
import 'package:m3t_api/src/models/user.dart';

/// Signature for a callback that returns the stored auth token (or null).
typedef TokenProvider = Future<String?> Function();

class M3tApiClient {
  M3tApiClient({
    http.Client? httpClient,
    String? baseUrl,
    TokenProvider? tokenProvider,
  }) : _httpClient = httpClient ?? http.Client(),
       _baseUrl = baseUrl ?? 'http://10.0.2.2:8080',
       _tokenProvider = tokenProvider;

  final http.Client _httpClient;
  final TokenProvider? _tokenProvider;
  final String _baseUrl;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Map<String, String> get _jsonHeaders => {
    'content-type': 'application/json',
  };

  Future<Map<String, String>> _authHeaders() async {
    final headers = Map<String, String>.of(_jsonHeaders);
    final token = await _tokenProvider?.call();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<void> requestLoginCode(String email) async {
    final response = await _httpClient.post(
      _uri('/auth/login/request'),
      headers: _jsonHeaders,
      body: jsonEncode(<String, String>{'email': email}),
    );

    if (response.statusCode != 200) {
      throw RequestLoginCodeFailure(
        'Request failed with status ${response.statusCode}',
      );
    }

    final body = _decodeJson(response.body);
    final errorJson = body['error'] as Map<String, dynamic>?;
    if (errorJson != null) {
      final error = ApiError.fromJson(errorJson);
      throw RequestLoginCodeFailure(error.message);
    }
  }

  Future<LoginResponse> verifyLoginCode({
    required String email,
    required String code,
  }) async {
    final response = await _httpClient.post(
      _uri('/auth/login/verify'),
      headers: _jsonHeaders,
      body: jsonEncode(<String, String>{
        'email': email,
        'code': code,
      }),
    );

    if (response.statusCode != 200) {
      throw VerifyLoginCodeFailure(
        'Request failed with status ${response.statusCode}',
      );
    }

    final body = _decodeJson(response.body);
    final errorJson = body['error'] as Map<String, dynamic>?;
    if (errorJson != null) {
      final error = ApiError.fromJson(errorJson);
      throw VerifyLoginCodeFailure(error.message);
    }

    final dataJson = body['data'] as Map<String, dynamic>?;
    if (dataJson == null) {
      throw VerifyLoginCodeFailure('Missing data field in response');
    }

    return LoginResponse.fromJson(dataJson);
  }

  Future<User> getCurrentUser() async {
    final response = await _httpClient.get(
      _uri('/users/me'),
      headers: await _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw GetCurrentUserFailure(
        'Request failed with status ${response.statusCode}',
      );
    }

    final body = _decodeJson(response.body);
    final errorJson = body['error'] as Map<String, dynamic>?;
    if (errorJson != null) {
      final error = ApiError.fromJson(errorJson);
      throw GetCurrentUserFailure(error.message);
    }

    final dataJson = body['data'] as Map<String, dynamic>?;
    if (dataJson == null) {
      throw GetCurrentUserFailure('Missing data field in response');
    }

    return User.fromJson(dataJson);
  }

  Future<User> updateCurrentUser({
    String? name,
    String? lastName,
  }) async {
    if (name == null && lastName == null) {
      throw ArgumentError(
        'At least one of name or lastName must be provided.',
      );
    }

    final body = <String, dynamic>{};
    if (name != null) {
      body['name'] = name;
    }
    if (lastName != null) {
      body['last_name'] = lastName;
    }

    final response = await _httpClient.patch(
      _uri('/users/me'),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw UpdateCurrentUserFailure(
        'Request failed with status ${response.statusCode}',
      );
    }

    final bodyJson = _decodeJson(response.body);
    final errorJson = bodyJson['error'] as Map<String, dynamic>?;
    if (errorJson != null) {
      final error = ApiError.fromJson(errorJson);
      throw UpdateCurrentUserFailure(error.message);
    }

    final dataJson = bodyJson['data'] as Map<String, dynamic>?;
    if (dataJson == null) {
      throw UpdateCurrentUserFailure('Missing data field in response');
    }

    return User.fromJson(dataJson);
  }

  Future<(Uri uploadUrl, String key)> requestAvatarUploadUrl() async {
    final response = await _httpClient.post(
      _uri('/users/me/avatar/upload-url'),
      headers: await _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw RequestAvatarUploadFailure(
        'Avatar upload URL request failed with status ${response.statusCode}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw RequestAvatarUploadFailure('Expected JSON object response');
    }

    final root = decoded;

    // Some endpoints wrap responses in a { data, error } envelope.
    final Map<String, dynamic>? data;
    if (root.containsKey('key') && root.containsKey('upload_url')) {
      data = root;
    } else {
      final nested = root['data'];
      data = nested is Map<String, dynamic> ? nested : null;
    }

    final key = data?['key'] as String?;
    final uploadUrl = data?['upload_url'] as String?;

    if (key == null || uploadUrl == null) {
      throw RequestAvatarUploadFailure('Missing key or upload_url in response');
    }

    return (Uri.parse(uploadUrl), key);
  }

  Future<void> uploadAvatarBytes({
    required Uri uploadUrl,
    required List<int> bytes,
    required String contentType,
  }) async {
    final response = await _httpClient.put(
      uploadUrl,
      headers: <String, String>{
        'content-type': contentType,
      },
      body: bytes,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw UploadAvatarFailure(
        'Avatar upload failed with status ${response.statusCode}',
      );
    }
  }

  Future<User> confirmAvatar({required String key}) async {
    final response = await _httpClient.put(
      _uri('/users/me/avatar'),
      headers: await _authHeaders(),
      body: jsonEncode(<String, String>{'key': key}),
    );

    if (response.statusCode != 200) {
      throw ConfirmAvatarFailure(
        'Confirm avatar failed with status ${response.statusCode}',
      );
    }

    final bodyJson = _decodeJson(response.body);
    final errorJson = bodyJson['error'] as Map<String, dynamic>?;
    if (errorJson != null) {
      final error = ApiError.fromJson(errorJson);
      throw ConfirmAvatarFailure(error.message);
    }

    final dataJson = bodyJson['data'] as Map<String, dynamic>?;
    if (dataJson == null) {
      throw ConfirmAvatarFailure('Missing data field in response');
    }

    return User.fromJson(dataJson);
  }

  /// Registers the authenticated user for the event identified by [eventCode]
  /// (4 characters). Idempotent: returns 200 if already registered, 201 if new.
  Future<EventRegistration> registerForEventByCode(String eventCode) async {
    final response = await _httpClient.post(
      _uri('/attendee/registrations'),
      headers: await _authHeaders(),
      body: jsonEncode(<String, String>{'event_code': eventCode}),
    );

    final body = _decodeJson(response.body);
    final errorJson = body['error'] as Map<String, dynamic>?;
    final apiError = errorJson != null ? ApiError.fromJson(errorJson) : null;
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw RegisterForEventByCodeFailure(
        apiError?.message ?? 'Request failed with status ${response.statusCode}',
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

  Map<String, dynamic> _decodeJson(String source) {
    final decoded = jsonDecode(source);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw const FormatException('Expected JSON object response');
  }
}
