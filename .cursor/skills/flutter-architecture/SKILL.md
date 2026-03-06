---
name: flutter-architecture
description: Layered architecture (presentation, domain, data), dependency direction, feature structure, and DI for this Flutter app. Use when discussing app structure, new features, or project organization.
---

# Flutter Architecture (m3t_attendee)

## When to Use

- Working on app structure, adding a new feature, or clarifying dependency direction.
- Deciding where new code belongs (presentation vs domain vs data).
- Setting up dependency injection or feature folders.

## Instructions

1. **Three layers:** Presentation (`lib/`), Domain (`packages/domain/`), Data (`packages/auth_repository/`, `packages/m3t_api/`). Dependencies flow top-down only.
2. **Presentation** depends on domain; it uses repository interfaces from `package:domain/domain.dart`. Data packages are wired only in `bootstrap.dart`.
3. **Domain** has no dependency on other packages or Flutter — pure Dart (e.g. `equatable` only).
4. **Packages never depend on `lib/`.** The app depends on packages, not the other way around.
5. **Feature structure:** Each feature under `lib/features/<feature_name>/` with `bloc/`, `view/`, and a barrel file `<feature>.dart` that exports `bloc/bloc.dart` and `view/view.dart`. App shell (router, auth BLoC) lives under `lib/app/`.
6. **DI:** No get_it or injectable. Compose in `bootstrap()` — token storage → API client (with token provider) → repository impl → `authRepository.initialize()` → `runApp(App(authRepository: ...))`. In the tree, `App` provides `AuthRepository` via `RepositoryProvider<AuthRepository>.value`; BLoCs get it with `context.read<AuthRepository>()` in `BlocProvider` create.

## References

- `lib/bootstrap.dart` — dependency composition
- `lib/app/view/app.dart` — app shell, router, providers
- `lib/app/routes.dart` — route constants
- `packages/domain/lib/src/repositories/auth_repository.dart` — repository interface
- `.cursor/rules/flutter-architecture.mdc` — full rule
