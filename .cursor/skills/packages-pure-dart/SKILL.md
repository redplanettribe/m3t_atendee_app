---
name: packages-pure-dart
description: Packages are pure Dart — no Flutter. Domain interfaces, data implementations, API models, mappers, ports. Use when working under packages/.
---

# Packages: Pure Dart Only

## When to Use

- Editing or adding code under `packages/`.
- Defining domain contracts, repository implementations, or API models.

## Instructions

1. **No Flutter in packages:** Do not import `package:flutter/...` or `dart:ui`. Platform behavior (e.g. secure storage) is behind ports; implementations live in `lib/infrastructure/` and are injected from `bootstrap.dart`.
2. **Domain (`packages/domain/`):** Repository contracts as `abstract interface class <Name>Repository`. Entities extend `Equatable`. Typed failure classes. Enums in `domain/lib/src/enums/`. Dependencies: only pure Dart (e.g. `equatable`). No `m3t_api`, no `auth_repository`, no Flutter.
3. **Data packages:** Implementations as `final class <Name>Impl implements <Interface>`. Constructor-inject dependencies. API client uses `http`, throws specific exceptions per endpoint, uses `TokenProvider` for auth. API models in `m3t_api/lib/src/models/` with `@JsonSerializable(fieldRename: FieldRename.snake)`, Equatable, part '.g.dart', fromJson/toJson, manual copyWith. Mappers: extension methods e.g. `extension UserMapper on User { AuthUser toDomain() => ... }`. Ports: abstract interfaces for platform (e.g. `TokenStorage`); app provides implementations.
4. **Package tests:** Use the `test` package (`import 'package:test/test.dart';`), not `flutter_test`.

## References

- `packages/domain/lib/src/repositories/auth_repository.dart`, `entities/auth_user.dart`, `failures/auth_failure.dart`
- `packages/auth_repository/lib/src/auth_repository.dart`, `mappers/user_mapper.dart`, `ports/token_storage.dart`
- `packages/m3t_api/lib/src/m3t_api_client.dart`, `models/user.dart`
- `.cursor/rules/packages-pure-dart.mdc` — full rule
