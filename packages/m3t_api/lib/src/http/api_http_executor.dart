import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:m3t_api/src/m3t_api_client.dart';

/// Low-level HTTP infrastructure shared by all data sources.
///
/// Owns the [http.Client], base URL, object-store URL, and token provider.
/// Exposes helpers used by every data source: [uri], [jsonHeaders],
/// [authHeaders], and [decodeJson].
///
/// Never throws domain-level failures — callers are responsible for mapping
/// HTTP status codes to typed exceptions.
final class ApiHttpExecutor {
  const ApiHttpExecutor({
    required http.Client httpClient,
    required String baseUrl,
    Uri? objectStoreBaseUrl,
    TokenProvider? tokenProvider,
  }) : _httpClient = httpClient,
       _baseUrl = baseUrl,
       _objectStoreBaseUrl = objectStoreBaseUrl,
       _tokenProvider = tokenProvider;

  final http.Client _httpClient;
  final String _baseUrl;
  final Uri? _objectStoreBaseUrl;
  final TokenProvider? _tokenProvider;

  /// Returns the [_objectStoreBaseUrl], used when rewriting presigned URLs
  /// for emulator or local device reachability.
  Uri? get objectStoreBaseUrl => _objectStoreBaseUrl;

  /// The underlying HTTP client — data sources use this directly for requests.
  http.Client get client => _httpClient;

  Uri uri(String path) => Uri.parse('$_baseUrl$path');

  Map<String, String> get jsonHeaders => {
    'content-type': 'application/json',
  };

  Future<Map<String, String>> authHeaders() async {
    final headers = Map<String, String>.of(jsonHeaders);
    final token = await _tokenProvider?.call();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic> decodeJson(String source) {
    final decoded = jsonDecode(source);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const FormatException('Expected JSON object response');
  }
}
