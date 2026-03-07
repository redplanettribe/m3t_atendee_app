import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:m3t_attendee/core/app_config.dart';

/// Resolves backend media paths into UI-safe absolute URLs.
///
/// Responsibilities:
/// - trims and rejects empty values
/// - resolves relative paths against the app backend base URL
/// - rewrites Android emulator localhost access transparently
abstract final class MediaUrlResolver {
  static final Uri _baseUri = Uri.parse(AppConfig.baseUrl);

  static String? resolveAppUrl(String? rawUrl) {
    final normalized = _normalize(rawUrl);
    if (normalized == null) return null;

    final absoluteUrl = _toAbsoluteUrl(normalized);
    return _resolveForCurrentPlatform(absoluteUrl);
  }

  static String? _normalize(String? rawUrl) {
    final normalized = rawUrl?.trim();
    if (normalized == null || normalized.isEmpty) return null;
    return normalized;
  }

  static String _toAbsoluteUrl(String rawUrl) {
    final uri = Uri.tryParse(rawUrl);
    if (uri != null && uri.hasScheme) return rawUrl;
    return _baseUri.resolve(rawUrl).toString();
  }

  static String _resolveForCurrentPlatform(String absoluteUrl) {
    if (defaultTargetPlatform == .android &&
        absoluteUrl.contains('localhost')) {
      return absoluteUrl.replaceFirst('localhost', '10.0.2.2');
    }
    return absoluteUrl;
  }
}
