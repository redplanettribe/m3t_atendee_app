# domain

The innermost layer of the m3t Attendee app. Pure Dart — no Flutter, no network, no storage. Everything else depends on this; this depends on nothing except `equatable`.

---

## What's in here

**`AuthUser`** — represents an authenticated user. Has `id`, `email`, and optional `name`, `lastName`, `createdAt`, `updatedAt`. Immutable with `copyWith`.

**`AuthStatus`** — three states: `unknown`, `authenticated`, `unauthenticated`. `unknown` is the initial state, held until `AuthRepository.initialize()` resolves — this is what prevents any auth redirect flash on startup.

**`AuthFailure`** — a sealed class hierarchy so every failure variant is handled at compile time:

```dart
sealed class AuthFailure implements Exception {}

final class InvalidEmail  extends AuthFailure {}
final class InvalidCode   extends AuthFailure {}
final class NetworkError  extends AuthFailure {}
final class UnknownError  extends AuthFailure {}
```

**`AuthRepository`** — the interface that `auth_repository` implements:

```dart
abstract interface class AuthRepository {
  Stream<AuthStatus> get status;
  AuthStatus get currentStatus;
  AuthUser? get currentUser;

  Future<void> initialize();
  Future<void> requestLoginCode(String email);
  Future<AuthUser> verifyLoginCode({required String email, required String code});
  Future<void> logout();
  Future<void> dispose();
}
```

---

## Testing

```bash
dart test
```
