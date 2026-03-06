# Setup New Feature

## Overview

Set up a new feature in this Flutter app following the project's layered architecture (presentation → BLoC/Cubit → domain), feature folder structure, and GoRouter. Use the project rules and skills (flutter-architecture, bloc-conventions, go-router) when implementing.

## Steps

1. **Define scope**
   - Clarify feature name and purpose (e.g. "events list", "profile edit").
   - Decide if it needs a new screen (new route) or lives inside an existing screen.
   - Decide if it needs only UI state (Cubit) or multiple event types (Bloc). If it calls the backend, it will need a repository (domain interface + data implementation); prefer using existing `AuthRepository` or add a new one in `packages/domain` and a corresponding impl in `packages/`.

2. **Create feature folder**
   - Add `lib/features/<feature_name>/` (snake_case folder name).
   - Add `bloc/`: `<feature>_bloc.dart` with `part '<feature>_event.dart'; part '<feature>_state.dart';` (or `<feature>_cubit.dart` + `<feature>_state.dart` for a Cubit). Add barrel `bloc/bloc.dart` that exports the bloc, event, and state files.
   - Add `view/`: at least one page or widget (e.g. `<feature>_page.dart`). Add `view/view.dart` that exports the public widgets.
   - Add `<feature>.dart` at the feature root that exports `bloc/bloc.dart` and `view/view.dart`.

3. **Implement BLoC or Cubit**
   - Follow bloc-conventions: sealed events + Equatable state, part files, copyWith with sentinel for nullable fields. Inject only domain repository interfaces (e.g. `AuthRepository`) via constructor.
   - Register the BLoC/Cubit in the widget tree (e.g. in the page with `BlocProvider`/`BlocProvider`, getting the repository via `context.read<AuthRepository>()`).

4. **Add route (if new screen)**
   - Add path constants in `lib/app/routes.dart` (`AppRoutes`) and a `GoRoute` in `lib/app/view/app.dart` that builds the new page. Use `AppRoutes.*` only; no raw path strings.

5. **Wire navigation**
   - From other screens, navigate with `context.push(AppRoutes.<newRoute>)` or `context.go(...)` using the new constant.

## Checklist

- [ ] Feature folder `lib/features/<name>/` with `bloc/`, `view/`, and barrel `<name>.dart`
- [ ] BLoC or Cubit follows project conventions (sealed events, Equatable state, part files, repository injection)
- [ ] View exports via `view/view.dart`; feature barrel exports bloc and view
- [ ] If new screen: route constant in `AppRoutes` and `GoRoute` in app router
- [ ] No business logic in widgets; no direct use of `M3tApiClient` in lib/ (use repository interfaces)
