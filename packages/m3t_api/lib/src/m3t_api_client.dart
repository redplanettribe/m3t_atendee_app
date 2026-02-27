import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models/api_error.dart';
import 'models/login_response.dart';

class RequestLoginCodeFailure implements Exception {
  RequestLoginCodeFailure(this.message);

  final String message;

  @override
  String toString() => 'RequestLoginCodeFailure($message)';
}

class VerifyLoginCodeFailure implements Exception {
  VerifyLoginCodeFailure(this.message);

  final String message;

  @override
  String toString() => 'VerifyLoginCodeFailure($message)';
}

class M3tApiClient {
  M3tApiClient({
    http.Client? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? 'http://10.0.2.2:8080';

  final http.Client _httpClient;
  final String _baseUrl;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<void> requestLoginCode(String email) async {
    final response = await _httpClient.post(
      _uri('/auth/login/request'),
      headers: <String, String>{
        'content-type': 'application/json',
      },
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
      headers: <String, String>{
        'content-type': 'application/json',
      },
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

  Map<String, dynamic> _decodeJson(String source) {
    final dynamic decoded = jsonDecode(source);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw const FormatException('Expected JSON object response');
  }
}

