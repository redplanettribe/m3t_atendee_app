import 'dart:convert';

import 'package:m3t_api/src/exceptions.dart';
import 'package:m3t_api/src/http/api_http_executor.dart';
import 'package:m3t_api/src/models/api_error.dart';
import 'package:m3t_api/src/models/login_response.dart';

/// Handles authentication API calls: request and verify login codes.
final class AuthDataSource {
  const AuthDataSource({required ApiHttpExecutor executor})
    : _executor = executor;

  final ApiHttpExecutor _executor;

  Future<void> requestLoginCode(String email) async {
    final response = await _executor.client.post(
      _executor.uri('/auth/login/request'),
      headers: _executor.jsonHeaders,
      body: jsonEncode(<String, String>{'email': email}),
    );

    if (response.statusCode != 200) {
      throw RequestLoginCodeFailure(
        'Request failed with status ${response.statusCode}',
      );
    }

    final body = _executor.decodeJson(response.body);
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
    final response = await _executor.client.post(
      _executor.uri('/auth/login/verify'),
      headers: _executor.jsonHeaders,
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

    final body = _executor.decodeJson(response.body);
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
}
