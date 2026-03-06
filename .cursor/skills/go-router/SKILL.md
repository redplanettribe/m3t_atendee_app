---
name: go-router
description: GoRouter setup — route constants in AppRoutes, refreshListenable for auth, redirect logic, nested routes, MaterialApp.router. Use when adding or changing routes or navigation.
---

# GoRouter Conventions

## When to Use

- Adding or changing navigation or routes.
- Configuring auth-based redirects or nested routes.

## Instructions

1. **Route constants:** Define all paths in `lib/app/routes.dart`. Use `abstract final class AppRoutes { ... }`. Full paths (e.g. `/login`, `/config`) for programmatic navigation: `context.push(AppRoutes.updateUser)`, `context.go(AppRoutes.home)`. Segment-only constants (e.g. `updateUserSegment` for `update-user`) for nested `GoRoute.path`. Never use raw string literals for routes; always `AppRoutes.*`.
2. **Router lifecycle:** Create the GoRouter in the State of the widget that owns it (e.g. `_AppViewState`), in `initState()`, and dispose in `dispose()`. Do not use a global or static router.
3. **App shell:** Use `MaterialApp.router(routerConfig: _router)`. Do not use `MaterialApp()` with `home` and imperative `Navigator` for the main shell.
4. **Auth-reactive routing:** Use `refreshListenable: GoRouterRefreshStream<AuthState>(authBloc.stream)` from `lib/app/router.dart`. In `redirect`, read current auth status and `routerState.matchedLocation`; return path to redirect or `null`. Typical logic: authenticated on login path → redirect to home; unauthenticated not on login → redirect to login. Use a `switch` on auth status for clarity.
5. **Nested routes:** Group related screens with nested `routes` (e.g. config + update-user: parent `AppRoutes.config`, child `AppRoutes.updateUserSegment`).

## References

- `lib/app/routes.dart` — route constants
- `lib/app/view/app.dart` — router creation, redirect, routes, MaterialApp.router
- `lib/app/router.dart` — GoRouterRefreshStream
- `.cursor/rules/go-router.mdc` — full rule
