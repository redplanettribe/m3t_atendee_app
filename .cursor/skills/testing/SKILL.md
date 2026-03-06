---
name: testing
description: Testing conventions — bloc_test, mocktail, test layout, buildBloc helper, assertions. Use when writing or editing tests.
---

# Testing Conventions

## When to Use

- Writing or editing tests (unit, bloc, widget).
- Adding tests for a new feature or BLoC.

## Instructions

1. **Layout:** Mirror source. `test/<feature>/bloc/<feature>_bloc_test.dart`, `_event_test.dart`, `_state_test.dart`. App-level under `test/app/bloc/`, `test/infrastructure/`. Package tests under each package's `test/`.
2. **BLoC/Cubit tests:** Use `bloc_test` — `blocTest<BlocType, StateType>('description', build: ..., act: ..., expect: ..., verify: ...)`. Mocks with **mocktail**; use private mocks: `class _MockAuthRepository extends Mock implements AuthRepository {}`.
3. **Build helper:** Define `buildBloc()` (or `buildCubit()`) that creates the bloc with injected mocks; pass as `build: buildBloc` in `blocTest`.
4. **setUp / tearDown:** Keep inside the same `group()` that uses them. In tearDown, cancel streams/controllers (e.g. `StreamController.close()`).
5. **Stubbing:** `when(() => mock.method()).thenReturn(...)` for sync; `when(() => mock.method()).thenAnswer((_) async => ...)` for async.
6. **Verification:** Use `verify(() => mock.method()).called(1)` in the `verify` callback of `blocTest` when testing side effects.
7. **Initial state:** Use `seed: () => const SomeState(...)` when the test needs a non-default initial state.
8. **Expectations:** Prefer `expect: () => const [State1(...), State2(...)]`. In plain `test()`, use matchers (e.g. `equals(...)`).
9. **Event/state unit tests:** Test value equality and `props` for events; for states test equality, `props`, and `copyWith` behavior.
10. **General:** Every test must assert (`expect` or `verify`). One scenario per test. No shared mutable state; create mocks in `setUp`.
11. **Packages:** In `packages/*` use the `test` package, not `flutter_test`.

## References

- `test/app/bloc/auth_bloc_test.dart`
- `test/login/bloc/login_bloc_test.dart`
- `test/user/user_cubit_test.dart`
- `packages/auth_repository/test/auth_repository_test.dart`
- `.cursor/rules/testing.mdc` — full rule
