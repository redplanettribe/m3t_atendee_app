import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:m3t_attendee/app/bloc/auth_bloc.dart';
import 'package:m3t_attendee/app/routes.dart';
import 'package:m3t_attendee/user/bloc/user_cubit.dart';
import 'package:m3t_attendee/user/view/user_avatar.dart';

/// User profile configuration page.
///
/// Displays the user's avatar, navigates to profile editing, and provides
/// logout. All navigation uses [AppRoutes] — no raw string literals.
final class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Align(
            alignment: .topCenter,
            child: BlocBuilder<UserCubit, UserState>(
              builder: (context, state) => Column(
                mainAxisSize: .min,
                children: [
                  UserAvatar(user: state.user, radius: 64),
                  const SizedBox(height: 24),
                  ListTile(
                    title: const Text('Update profile'),
                    onTap: () => context.push(AppRoutes.updateUser),
                  ),
                  ListTile(
                    title: const Text('Logout'),
                    onTap: () => context.read<AuthBloc>().add(
                      const AuthLogoutRequested(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
