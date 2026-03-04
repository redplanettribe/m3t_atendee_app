import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:m3t_attendee/app/routes.dart';
import 'package:m3t_attendee/user/bloc/user_cubit.dart';
import 'package:m3t_attendee/user/view/user_avatar.dart';

/// Circular avatar button showing the authenticated user's photo or initials.
///
/// Tapping navigates to [AppRoutes.config].
final class UserAvatarButton extends StatelessWidget {
  const UserAvatarButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) => InkWell(
        onTap: () => context.push(AppRoutes.config),
        customBorder: const CircleBorder(),
        child: UserAvatar(user: state.user, radius: 22),
      ),
    );
  }
}
