import 'package:auth_repository/auth_repository.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:m3t_attendee/login/login.dart';
import 'package:m3t_attendee/user/user_cubit.dart';
import 'package:m3t_attendee/user/view/update_user_page.dart';
import 'package:m3t_api/m3t_api.dart';

/// Resolves image URLs for the current platform. On Android, replaces
/// `localhost` with `10.0.2.2` so the emulator can reach the host machine.
String? _resolveImageUrl(String? url) {
  if (url == null || url.isEmpty) return url;
  if (defaultTargetPlatform == TargetPlatform.android &&
      url.contains('localhost')) {
    return url.replaceFirst('localhost', '10.0.2.2');
  }
  return url;
}

/// Returns initials for [user] (e.g. from name + lastName or email), or '?' if none.
String _userInitials(User? user) {
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

class App extends StatelessWidget {
  const App({
    required AuthRepository authRepository,
    super.key,
  }) : _authRepository = authRepository;

  final AuthRepository _authRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _authRepository,
      child: BlocProvider(
        create: (context) =>
            UserCubit(context.read<AuthRepository>())..loadCurrentUser(),
        child: const _AppView(),
      ),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  late final GoRouter _router;
  AuthStatus _authStatus = AuthStatus.unknown;

  @override
  void initState() {
    super.initState();
    final authRepository = context.read<AuthRepository>();
    authRepository.status.listen((status) {
      if (mounted) {
        setState(() => _authStatus = status);
      }
    });

    _router = GoRouter(
      refreshListenable: _AuthNotifier(authRepository),
      redirect: (context, state) {
        final isOnLogin = state.matchedLocation == '/login';
        if (_authStatus == AuthStatus.unauthenticated && !isOnLogin) {
          return '/login';
        }
        if (_authStatus == AuthStatus.authenticated && isOnLogin) {
          return '/';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const _HomePage(),
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
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

/// Converts the [AuthRepository.status] stream into a [ChangeNotifier]
/// so [GoRouter.refreshListenable] can react to auth changes.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(AuthRepository authRepository) {
    _subscription = authRepository.status.listen((_) {
      notifyListeners();
    });
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 72,
        leading: Padding(
          padding: EdgeInsets.only(left: 16),
          child: _UserAvatarButton(),
        ),
      ),
      body: Center(
        child: Text(
          'Welcome!',
          style: theme.textTheme.headlineMedium,
        ),
      ),
    );
  }
}

class _UserAvatarButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        final user = state.user;
        Widget avatar;
        final initials = _userInitials(user);
        if (user?.profilePictureUrl != null &&
            user!.profilePictureUrl!.isNotEmpty) {
          avatar = CircleAvatar(
            radius: 22,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: ClipOval(
              child: Image.network(
                _resolveImageUrl(user.profilePictureUrl)!,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      initials,
                      style:
                          Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                  );
                },
              ),
            ),
          );
        } else {
          avatar = CircleAvatar(
            radius: 22,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              initials,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
            ),
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
                final avatar = (user?.profilePictureUrl != null &&
                        user!.profilePictureUrl!.isNotEmpty)
                    ? CircleAvatar(
                        radius: 64,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: ClipOval(
                          child: Image.network(
                            _resolveImageUrl(user.profilePictureUrl)!,
                            width: 128,
                            height: 128,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  initials,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : CircleAvatar(
                        radius: 64,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          initials,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      );

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    avatar,
                    const SizedBox(height: 24),
                    ListTile(
                      title: const Text('Update user'),
                      onTap: () {
                        context.push('/config/update-user');
                      },
                    ),
                    ListTile(
                      title: const Text('Logout'),
                      onTap: () {
                        context.read<AuthRepository>().logout();
                      },
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
