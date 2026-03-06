---
name: bloc-conventions
description: BLoC and Cubit conventions — sealed events, Equatable state, part files, copyWith sentinel, error handling. Use when creating or editing a BLoC or Cubit.
---

# BLoC / Cubit Conventions

## When to Use

- Adding or editing a BLoC or Cubit in this project.
- Defining events, state, or event handlers.

## Instructions

1. **File layout:** One main file with `part` files. `lib/features/<feature>/bloc/<feature>_bloc.dart` has `part '..._event.dart'; part '..._state.dart';` and the Bloc class. Event and state files use `part of '<feature>_bloc.dart';`. Barrel: `bloc/bloc.dart` exports all three (or two for Cubit).
2. **Events (Bloc only):** `sealed class <Feature>Event extends Equatable` with `final class` subclasses. All const constructors. Override `List<Object?> get props` with all fields.
3. **State:** `final class <Feature>State extends Equatable`. Use enums for status/step when helpful. For nullable fields in `copyWith`, use a sentinel so "omit" and "set to null" are distinct (see rule for snippet).
4. **Bloc vs Cubit:** Use Bloc for multiple event types and event-driven flows; use Cubit for a single flow with methods like `loadCurrentUser()`.
5. **Dependencies:** Blocs/Cubits depend only on repository interfaces from `package:domain/domain.dart`. Inject via constructor; app provides with `context.read<AuthRepository>()` in `BlocProvider` create.
6. **Error handling:** In handlers, try repository call, emit new state; on exception use `addError(error, stackTrace)` and emit state with failure status and user-facing `errorMessage` (e.g. from `AuthFailure.toDisplayMessage()`). For stream-based auth, subscribe to `authRepository.status` in constructor and cancel in `close()`.
7. **Lifecycle:** Override `close()` to cancel subscriptions and call repository cleanup (e.g. `authRepository.dispose()`) when the Bloc owns it.

## References

- `lib/app/bloc/auth_bloc.dart`, `auth_event.dart`, `auth_state.dart`
- `lib/features/login/bloc/login_bloc.dart`, `login_event.dart`, `login_state.dart`
- `lib/features/user/bloc/user_cubit.dart`, `user_state.dart`
- `.cursor/rules/bloc-conventions.mdc` — full rule
