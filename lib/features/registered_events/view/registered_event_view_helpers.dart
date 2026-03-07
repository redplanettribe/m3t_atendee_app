import 'package:domain/domain.dart';
import 'package:m3t_attendee/core/media/media_url_resolver.dart';

/// Presentation helpers for registered event rendering.
extension RegisteredEventDisplayExtension on RegisteredEventEntity {
  /// UI-safe thumbnail URL resolved for the current app runtime.
  String? get resolvedThumbnailUrl =>
      MediaUrlResolver.resolveAppUrl(thumbnailUrl);
}
