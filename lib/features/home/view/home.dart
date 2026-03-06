import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:m3t_attendee/app/routes.dart';
import 'package:m3t_attendee/features/user/view/user_avatar_button.dart';

final class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: UserAvatarButton(),
        ),
        title: const Text('m3t Attendee'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Register for event',
            onPressed: () => context.push(AppRoutes.registerForEvent),
          ),
        ],
      ),
      body: Center(child: Text('Welcome!', style: textTheme.headlineMedium)),
    );
  }
}
