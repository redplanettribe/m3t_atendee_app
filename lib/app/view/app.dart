import 'dart:async' show unawaited;

import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:m3t_attendee/app/bloc/auth_bloc.dart';
import 'package:m3t_attendee/app/router.dart';
import 'package:m3t_attendee/home/home.dart';
import 'package:m3t_attendee/login/login.dart';
import 'package:m3t_attendee/user/user_cubit.dart';
import 'package:m3t_attendee/user/view/update_user_page.dart';

// ---------------------------------------------------------------------------
// File-level helpers (view-layer utilities — no business logic)
// ---------------------------------------------------------------------------

/// Resolves image URLs for the current platform.
/// On Android, swaps `localhost` for `10.0.2.2` so the emulator can reach
/// the host machine.
String? _resolveImageUrl(String? url) {
  if (url == null || url.isEmpty) return url;
  if (defaultTargetPlatform == TargetPlatform.android &&
      url.contains('localhost')) {
    return url.replaceFirst('localhost', '10.0.2.2');
  }
  return url;
}

/// Returns up-to-two-character initials for [user], or '?' when unavailable.
String _userInitials(AuthUser? user) {
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

// ---------------------------------------------------------------------------
// App root
// ---------------------------------------------------------------------------

/// Root widget. Owns the repository and BLoC composition.
final class App extends StatelessWidget {
  const App({required AuthRepository authRepository, super.key})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthRepository>.value(
      value: _authRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(authRepository: context.read()),
          ),
          BlocProvider<UserCubit>(
            create: (context) {
              final cubit = UserCubit(authRepository: context.read());
              unawaited(cubit.loadCurrentUser());
              return cubit;
            },
          ),
        ],
        child: const _AppView(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _AppView (router host)
// ---------------------------------------------------------------------------

final class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

final class _AppViewState extends State<_AppView> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authBloc = context.read<AuthBloc>();

    _router = GoRouter(
      refreshListenable: GoRouterRefreshStream<AuthState>(authBloc.stream),
      redirect: (_, routerState) {
        final authStatus = authBloc.state.status;
        final isOnLogin = routerState.matchedLocation == '/login';

        return switch (authStatus) {
          AuthStatus.authenticated when isOnLogin => '/',
          AuthStatus.unauthenticated when !isOnLogin => '/login',
          _ => null,
        };
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/config',
          builder: (context, state) => const _ConfigPage(),
          routes: [
            GoRoute(
              path: 'update-user',
              builder: (context, state) => const UpdateUserPage(),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'm3t Attendee',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      routerConfig: _router,
    );
  }
}

// // ---------------------------------------------------------------------------
// // Home page
// // ---------------------------------------------------------------------------

// class _HomePage extends StatelessWidget {
//   const _HomePage();

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Scaffold(
//       appBar: AppBar(
//         leadingWidth: 72,
//         leading: const Padding(
//           padding: EdgeInsets.only(left: 16),
//           child: _UserAvatarButton(),
//         ),
//       ),
//       body: Center(
//         child: Text('Welcome!', style: theme.textTheme.headlineMedium),
//       ),
//     );
//   }
// }

// ---------------------------------------------------------------------------
// User avatar button
// ---------------------------------------------------------------------------

class _UserAvatarButton extends StatelessWidget {
  const _UserAvatarButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        final user = state.user;
        final initials = _userInitials(user);
        final colorScheme = Theme.of(context).colorScheme;
        final textStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          color: colorScheme.onPrimaryContainer,
          fontWeight: .w600,
        );

        Widget avatar;
        final resolvedUrl = _resolveImageUrl(user?.profilePictureUrl);
        if (resolvedUrl != null && resolvedUrl.isNotEmpty) {
          avatar = CircleAvatar(
            radius: 22,
            backgroundColor: colorScheme.primaryContainer,
            child: ClipOval(
              child: Image.network(
                resolvedUrl,
                width: 44,
                height: 44,
                fit: .cover,
                errorBuilder: (_, _, _) => Center(
                  child: Text(initials, style: textStyle),
                ),
              ),
            ),
          );
        } else {
          avatar = CircleAvatar(
            radius: 22,
            backgroundColor: colorScheme.primaryContainer,
            child: Text(initials, style: textStyle),
          );
        }

        return GestureDetector(
          onTap: () => context.push('/config'),
          child: avatar,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Config page
// ---------------------------------------------------------------------------

class _ConfigPage extends StatelessWidget {
  const _ConfigPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Align(
            alignment: Alignment.topCenter,
            child: BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                final user = state.user;
                final initials = _userInitials(user);
                final colorScheme = Theme.of(context).colorScheme;
                final resolvedUrl = _resolveImageUrl(user?.profilePictureUrl);

                final Widget avatar;
                if (resolvedUrl != null && resolvedUrl.isNotEmpty) {
                  avatar = CircleAvatar(
                    radius: 64,
                    backgroundColor: colorScheme.primaryContainer,
                    child: ClipOval(
                      child: Image.network(
                        resolvedUrl,
                        width: 128,
                        height: 128,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Center(
                          child: Text(
                            initials,
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  avatar = CircleAvatar(
                    radius: 64,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      initials,
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  );
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    avatar,
                    const SizedBox(height: 24),
                    ListTile(
                      title: const Text('Update user'),
                      onTap: () => context.push('/config/update-user'),
                    ),
                    ListTile(
                      title: const Text('Logout'),
                      onTap: () => context.read<AuthRepository>().logout(),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
