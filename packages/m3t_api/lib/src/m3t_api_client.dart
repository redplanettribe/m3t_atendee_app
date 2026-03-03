import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:m3t_api/src/exceptions.dart';
import 'package:m3t_api/src/models/api_error.dart';
import 'package:m3t_api/src/models/login_response.dart';
import 'package:m3t_api/src/models/user.dart';

/// Signature for a callback that returns the stored auth token (or null).
typedef TokenProvider = Future<String?> Function();

/// HTTP client for the M3T API.
final class M3tApiClient {
  /// Creates an [M3tApiClient].
  ///
  /// [tokenProvider] is called on every authenticated request to retrieve the
  /// current bearer token. Pass [httpClient] and [baseUrl] to override
  /// defaults in tests.
  M3tApiClient({
    required TokenProvider tokenProvider,
    http.Client? httpClient,
    String? baseUrl,
  })  : _tokenProvider = tokenProvider,
        _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? 'http://10.0.2.2:8080';

  final TokenProvider _tokenProvider;
  final http.Client _httpClient;
  final String _baseUrl;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Map<String, String> get _jsonHeaders => const {
        'content-type': 'application/json',
      };

  Future<Map<String, String>> _authHeaders() async {
    final token = await _tokenProvider();
    return {
      'content-type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------

  /// Requests a one-time login code be sent to [email].
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

  /// Verifies [code] for [email] and returns a [LoginResponse] on success.
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

  // ---------------------------------------------------------------------------
  // User profile
  // ---------------------------------------------------------------------------

  /// Returns the currently authenticated user.
  Future<User> getCurrentUser() async {
    final response = await _httpClient.get(
      _uri('/users/me'),
      headers: await _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Request failed with status ${response.statusCode}');
    }

    final body = _decodeJson(response.body);
    final errorJson = body['error'] as Map<String, dynamic>?;
    if (errorJson != null) {
      final error = ApiError.fromJson(errorJson);
      throw Exception(error.message);
    }

    final dataJson = body['data'] as Map<String, dynamic>?;
    if (dataJson == null) {
      throw const FormatException('Missing data field in response');
    }

    return User.fromJson(dataJson);
  }

  /// Updates the current user profile fields.
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
    if (name != null) body['name'] = name;
    if (lastName != null) body['last_name'] = lastName;

    final response = await _httpClient.patch(
      _uri('/users/me'),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Request failed with status ${response.statusCode}');
    }

    final bodyJson = _decodeJson(response.body);
    final errorJson = bodyJson['error'] as Map<String, dynamic>?;
    if (errorJson != null) {
      final error = ApiError.fromJson(errorJson);
      throw Exception(error.message);
    }

    final dataJson = bodyJson['data'] as Map<String, dynamic>?;
    if (dataJson == null) {
      throw const FormatException('Missing data field in response');
    }

    return User.fromJson(dataJson);
  }

  /// Requests a pre-signed S3 upload URL for the current user avatar.
  Future<(Uri uploadUrl, String key)> requestAvatarUploadUrl() async {
    final response = await _httpClient.post(
      _uri('/users/me/avatar/upload-url'),
      headers: await _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Avatar upload URL request failed with status ${response.statusCode}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected JSON object response');
    }

    final Map<String, dynamic> root = decoded;
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
      throw const FormatException('Missing key or upload_url in response');
    }

    return (Uri.parse(uploadUrl), key);
  }

  /// Uploads raw avatar [bytes] to the pre-signed [uploadUrl].
  Future<void> uploadAvatarBytes({
    required Uri uploadUrl,
    required List<int> bytes,
    required String contentType,
  }) async {
    final response = await _httpClient.put(
      uploadUrl,
      headers: <String, String>{'content-type': contentType},
      body: bytes,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Avatar upload failed with status ${response.statusCode}',
      );
    }
  }

  /// Confirms the uploaded avatar identified by [key].
  Future<User> confirmAvatar({required String key}) async {
    final response = await _httpClient.put(
      _uri('/users/me/avatar'),
      headers: await _authHeaders(),
      body: jsonEncode(<String, String>{'key': key}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Confirm avatar failed with status ${response.statusCode}',
      );
    }

    final bodyJson = _decodeJson(response.body);
    final errorJson = bodyJson['error'] as Map<String, dynamic>?;
    if (errorJson != null) {
      final error = ApiError.fromJson(errorJson);
      throw Exception(error.message);
    }

    final dataJson = bodyJson['data'] as Map<String, dynamic>?;
    if (dataJson == null) {
      throw const FormatException('Missing data field in response');
    }

    return User.fromJson(dataJson);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _decodeJson(String source) {
    final decoded = jsonDecode(source);
    if (decoded is Map<String, dynamic>) return decoded;
    throw const FormatException('Expected JSON object response');
  }
}
