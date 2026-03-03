# Changelog

All notable changes to this package will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This package adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-03-03

### Added

- `M3tApiClient` with `requestLoginCode(String email)` and `verifyLoginCode({email, code})` methods.
- `LoginResponse` DTO with `token`, `tokenType`, and `User`.
- `User` DTO with `id`, `email`, optional `name`, `lastName`, `createdAt`, `updatedAt` (ISO-8601 strings).
- `ApiError` DTO for structured backend error payloads.
- `RequestLoginCodeFailure` and `VerifyLoginCodeFailure` typed exceptions.
- `very_good_analysis` linting enforced via `analysis_options.yaml`.
