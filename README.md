# m3t Attendee

A Flutter app for m3t event attendees, built with Clean Architecture and a modular package structure.

---

## Architecture

```
┌─────────────────────────────────────────────┐
│                  App Layer                  │
│  (Flutter UI · BLoC · Router · bootstrap)   │
├─────────────────┬───────────────────────────┤
│  auth_repository│        m3t_api             │
│  (Infra/Adapter)│   (Remote Data Source)    │
├─────────────────┴───────────────────────────┤
│                   domain                    │
│   Entities · Failures · Repository ports    │
│          Pure Dart · No Flutter             │
└─────────────────────────────────────────────┘
```

- `domain` has no Flutter or third-party dependencies (except `equatable`).
- `auth_repository` implements the domain interface and is also pure Dart — infrastructure details are injected via a port.
- `bootstrap.dart` is the only place that knows about concrete implementations.
- State management: `flutter_bloc`. Navigation: `go_router` driven by `AuthBloc`.

---

## Package structure

```
lib/
├── main.dart                            # Entry point → bootstrap()
├── bootstrap.dart                       # Composition root
├── core/
│   ├── app_config.dart                  # --dart-define constants
│   └── auth/
│       └── auth_failure_message.dart    # AuthFailure → display string
├── infrastructure/
│   └── flutter_secure_token_storage.dart
├── app/
│   ├── bloc/                            # AuthBloc (app-lifetime session)
│   ├── routes.dart                      # AppRoutes constants
│   ├── router.dart                      # GoRouterRefreshStream
│   └── view/
└── features/
    ├── login/
    │   ├── bloc/                        # LoginBloc (screen-scoped)
    │   └── view/
    ├── user/
    │   ├── bloc/                        # UserCubit
    │   └── view/                        # UserAvatar, UserAvatarButton, ConfigPage, UpdateUserPage
    └── home/
        └── view/

packages/
├── domain/          # Pure Dart domain layer
├── auth_repository/ # AuthRepository implementation
└── m3t_api/         # REST client + DTOs
```

---

## Getting started

```bash
flutter pub get
```

The API base URL is injected at compile time via `--dart-define`. If the flag
is omitted the app falls back to `http://10.0.2.2:8080` (Android emulator
loopback — useful for local development).

```bash
# Remote server
flutter run --dart-define=BASE_URL=https://your-api-host.example.com

# Local backend (Android emulator default, no flag needed)
flutter run

# Production build
flutter build apk --dart-define=BASE_URL=https://your-api-host.example.com
flutter build ipa --dart-define=BASE_URL=https://your-api-host.example.com
```

The VS Code launch configuration passes the URL via `--dart-define` — just
update `.vscode/launch.json` with your target URL and press **Run > Start
Debugging** (`F5`).

## Running tests

```bash
# App layer
flutter test

# domain and auth_repository are pure Dart — no Flutter toolchain needed
dart test packages/domain
dart test packages/auth_repository
```

---

## Tech stack

| Concern | Package |
|---|---|
| State management | `flutter_bloc` |
| Navigation | `go_router` |
| Secure token storage | `flutter_secure_storage` |
| HTTP | `http` |
| Serialisation | `json_serializable` |
| Value equality | `equatable` |
| Linting | `very_good_analysis` |
| Testing | `flutter_test` · `bloc_test` · `mocktail` |
