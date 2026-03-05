import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;

/// Platform-aware image URL resolution.
///
/// On Android emulators `localhost` is not routable — this extension swaps it
/// for `10.0.2.2` (the host loopback alias) automatically.
extension PlatformImageUrlExtension on String? {
  /// Returns the URL resolved for the current platform, or the original value
  /// when no adjustment is needed.
  String? get platformResolved {
    final url = this;
    if (url == null || url.isEmpty) return url;
    if (defaultTargetPlatform == .android && url.contains('localhost')) {
      return url.replaceFirst('localhost', '10.0.2.2');
    }
    return url;
  }
}

/// User display utilities derived directly from domain data.
extension UserDisplayExtension on AuthUser? {
  /// Up-to-two-character initials for display in avatars.
  ///
  /// Priority: first + last name → first name alone → email local-part.
  /// Returns `'?'` when no data is available.
  String get initials {
    final user = this;
    if (user == null) return '?';
    final name = user.name?.trim();
    final lastName = user.lastName?.trim();
    if (name != null &&
        name.isNotEmpty &&
        lastName != null &&
        lastName.isNotEmpty) {
      return '${name[0]}${lastName[0]}'.toUpperCase();
    }
    if (name != null && name.isNotEmpty) {
      return name.length >= 2
          ? name.substring(0, 2).toUpperCase()
          : name[0].toUpperCase();
    }
    final email = user.email.trim();
    if (email.isNotEmpty) {
      final part = email.split('@').first;
      return part.length >= 2
          ? part.substring(0, 2).toUpperCase()
          : part[0].toUpperCase();
    }
    return '?';
  }
}
