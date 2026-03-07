import 'package:domain/domain.dart';
import 'package:m3t_attendee/core/media/media_url_resolver.dart';

/// User display utilities derived directly from domain data.
extension UserDisplayExtension on AuthUser? {
  /// Profile picture URL resolved for the current app runtime.
  String? get resolvedProfilePictureUrl =>
      MediaUrlResolver.resolveAppUrl(this?.profilePictureUrl);

  /// Up-to-two-character initials for display in avatars.
  ///
  /// Priority: first + last name -> first name alone -> email local-part.
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
