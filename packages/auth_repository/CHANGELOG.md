# Changelog

All notable changes to this package will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This package adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-03-03

### Added

- `AuthRepositoryImpl` implementing the `AuthRepository` domain interface.
- `TokenStorage` port (`abstract interface class`) for decoupled token persistence.
- `LoginResponseMapper` extension mapping `LoginResponse` DTOs to `AuthUser` domain entities.
- `initialize()` method that resolves auth status synchronously before `runApp()`, eliminating any redirect flash.
- Exception translation: `RequestLoginCodeFailure` → `NetworkError`, `VerifyLoginCodeFailure` → `InvalidCode`, unknown → `UnknownError`.
- Broadcast `Stream<AuthStatus>` for reactive session state.

### Changed

- Removed Flutter SDK dependency — package is now pure Dart.
- `FlutterSecureStorage` extracted to a `TokenStorage` adapter in the app layer, enforcing Ports & Adapters.
- Test suite migrated from `flutter_test` to `dart:test` with `_MockTokenStorage` replacing `_MockFlutterSecureStorage`.
