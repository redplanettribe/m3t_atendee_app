# Code Review Checklist

## Overview

Use this checklist when reviewing code in this repo. The app uses a three-layer architecture (presentation, domain, data), BLoC/Cubit, GoRouter, and pure-Dart packages. Apply the project rules (flutter-architecture, bloc-conventions, packages-pure-dart, testing, go-router, m3t-api-usage) when evaluating changes.

## Review Categories

### Architecture and layers

- [ ] New code lives in the correct layer: UI in `lib/features/*/view/`, business logic in `lib/**/bloc/`, domain in `packages/domain/`, data in `packages/auth_repository/` or `packages/m3t_api/`.
- [ ] Dependencies flow correctly: presentation → domain; data packages → domain; no package depends on `lib/`.
- [ ] No `M3tApiClient` or other data-layer types used directly in `lib/` (use repository interfaces from domain).
- [ ] `packages/` do not import `package:flutter/...` or `dart:ui`.

### BLoC / Cubit

- [ ] Events are sealed + final, state is Equatable; part files used for event/state.
- [ ] copyWith uses sentinel for nullable fields where "omit" vs "set to null" matters.
- [ ] BLoCs/Cubits depend only on repository interfaces (injected via constructor).
- [ ] Errors from repositories are mapped to domain failures and exposed as user-facing messages in state (e.g. `errorMessage`).

### Feature structure and routing

- [ ] New features under `lib/features/<name>/` with `bloc/`, `view/`, and barrel `<name>.dart`.
- [ ] Routes use `AppRoutes` constants only; no raw path strings. New routes added in `lib/app/routes.dart` and in the GoRouter config in `lib/app/view/app.dart`.

### API and data

- [ ] New API usage follows `docs/api/swagger.json` and the m3t_api client patterns (envelope, typed exceptions).
- [ ] New models in `packages/m3t_api` use `@JsonSerializable(fieldRename: FieldRename.snake)`, Equatable, and generated `.g.dart`; build_runner has been run.
- [ ] Repository implementations map client exceptions to domain failures.

### Tests

- [ ] New or changed behavior has tests. BLoC tests use `bloc_test` and `mocktail`; mocks are private (`_MockX`).
- [ ] Test layout mirrors source; `buildBloc()` and setUp/tearDown inside the relevant group.
- [ ] Package tests use the `test` package, not `flutter_test`.

### General

- [ ] No hardcoded secrets or sensitive data.
- [ ] Code follows existing style and passes `dart analyze` / project lints (e.g. very_good_analysis).
