import 'package:auth_repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:m3t_attendee/login/login.dart';

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
      child: const _AppView(),
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
        title: const Text('m3t Attendee'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthRepository>().logout(),
          ),
        ],
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
