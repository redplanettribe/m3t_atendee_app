import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_attendee/app/bloc/auth_bloc.dart';
import 'package:m3t_attendee/user/view/user_avatar_button.dart';

final class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: .only(left: 16),
          child: UserAvatarButton(),
        ),
        title: const Text('m3t Attendee'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthLogoutRequested()),
          ),
        ],
      ),
      body: Center(child: Text('Welcome!', style: textTheme.headlineMedium)),
    );
  }
}
