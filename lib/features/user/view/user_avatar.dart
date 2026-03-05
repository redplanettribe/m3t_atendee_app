import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder;
import 'package:m3t_attendee/features/user/view/user_view_helpers.dart';

/// Circular avatar for [user], showing their profile photo or initials
/// as a fallback.
///
/// Stateless and pure — has no Bloc dependency. Compose with [BlocBuilder]
/// at the call site to keep this widget independently testable and reusable
/// outside the user feature.
final class UserAvatar extends StatelessWidget {
  const UserAvatar({required this.user, required this.radius, super.key});

  final AuthUser? user;

  /// Radius of the circle in logical pixels.
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedUrl = user?.profilePictureUrl.platformResolved;
    final diameter = radius * 2;
    final style = _initialsStyle(theme);

    if (resolvedUrl != null && resolvedUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: theme.colorScheme.primaryContainer,
        child: ClipOval(
          child: Image.network(
            resolvedUrl,
            width: diameter,
            height: diameter,
            fit: .cover,
            errorBuilder: (_, _, _) =>
                Center(child: Text(user.initials, style: style)),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(user.initials, style: style),
    );
  }

  // Scales typography to radius: small avatars use titleSmall, large use
  // headlineLarge. Threshold of 48 lp matches the common 96-dp avatar size.
  TextStyle? _initialsStyle(ThemeData theme) =>
      (radius >= 48
              ? theme.textTheme.headlineLarge
              : theme.textTheme.titleSmall)
          ?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: .w600,
          );
}
