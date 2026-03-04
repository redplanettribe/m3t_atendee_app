# Changelog

All notable changes to this package will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This package adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2026-03-03

### Added

- `AuthUser` entity with `id`, `email`, optional `name`, `lastName`, `createdAt`, `updatedAt`, value equality via `Equatable`, and `copyWith`.
- `AuthStatus` enum with `unknown`, `authenticated`, and `unauthenticated` variants.
- `AuthFailure` sealed class implementing `Exception`, with variants `InvalidEmail`, `InvalidCode`, `NetworkError`, and `UnknownError`.
- `AuthRepository` abstract interface defining the contract for authentication: `status` stream, `currentStatus`, `currentUser`, `initialize()`, `requestLoginCode()`, `verifyLoginCode()`, `logout()`, and `dispose()`.
