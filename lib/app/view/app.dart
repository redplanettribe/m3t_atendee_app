import 'dart:async' show unawaited;

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:m3t_attendee/app/bloc/auth_bloc.dart';
import 'package:m3t_attendee/app/router.dart';
import 'package:m3t_attendee/app/routes.dart';
import 'package:m3t_attendee/features/home/home.dart';
import 'package:m3t_attendee/features/login/login.dart';
import 'package:m3t_attendee/features/register_for_event/register_for_event.dart';
import 'package:m3t_attendee/features/registered_events/cubit/registered_events_cubit.dart';
import 'package:m3t_attendee/features/registered_events/view/registered_events_page.dart';
import 'package:m3t_attendee/features/user/user.dart';

// ---------------------------------------------------------------------------
// App root
// ---------------------------------------------------------------------------

/// Root widget. Owns the repository and BLoC composition.
final class App extends StatelessWidget {
  const App({
    required AuthRepository authRepository,
    required AttendeeRepository attendeeRepository,
    super.key,
  }) : _authRepository = authRepository,
       _attendeeRepository = attendeeRepository;

  final AuthRepository _authRepository;
  final AttendeeRepository _attendeeRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: _authRepository),
        RepositoryProvider<AttendeeRepository>.value(
          value: _attendeeRepository,
        ),
      ],
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
          BlocProvider<RegisteredEventsCubit>(
            create: (context) {
              final cubit = RegisteredEventsCubit(
                attendeeRepository: context.read(),
              );
              unawaited(cubit.initialize());
              return cubit;
            },
          ),
        ],
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == .unauthenticated) {
              unawaited(context.read<RegisteredEventsCubit>().clear());
            }
          },
          child: const _AppView(),
        ),
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
        final isOnLogin = routerState.matchedLocation == AppRoutes.login;

        return switch (authStatus) {
          .authenticated when isOnLogin => AppRoutes.home,
          .unauthenticated when !isOnLogin => AppRoutes.login,
          _ => null,
        };
      },
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: AppRoutes.myEvents,
          builder: (context, state) {
            final initialTab = switch (state.extra) {
              final RegisteredEventsTab tab => tab,
              _ => null,
            };

            return RegisteredEventsPage(initialTab: initialTab);
          },
        ),
        GoRoute(
          path: AppRoutes.registerForEvent,
          builder: (context, state) => const RegisterForEventPage(),
        ),
        GoRoute(
          path: AppRoutes.config,
          builder: (context, state) => const ConfigPage(),
          routes: [
            GoRoute(
              path: AppRoutes.updateUserSegment,
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
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: Colors.deepPurple,
          brightness: .dark,
        ),
      ),
      routerConfig: _router,
    );
  }
}
