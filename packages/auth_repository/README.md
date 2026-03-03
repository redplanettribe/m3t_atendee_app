# auth_repository

Concrete implementation of the `AuthRepository` interface from the `domain` package. Pure Dart — no Flutter SDK dependency.

Responsibilities: auth lifecycle (init, request code, verify, logout), token persistence via a port, and translating `m3t_api` exceptions into domain failures.

---

## TokenStorage port

Token persistence is decoupled via a small port. The adapter lives in the app layer:

```dart
abstract interface class TokenStorage {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> delete();
}
```

## Usage

```dart
// In bootstrap.dart
final authRepository = AuthRepositoryImpl(
  apiClient: M3tApiClient(baseUrl: 'https://api.example.com'),
  tokenStorage: const FlutterSecureTokenStorage(),
);

// Await before runApp() — eliminates any auth-status flash
await authRepository.initialize();
```

---

## Exception mapping

| `m3t_api` exception | Domain failure |
|---|---|
| `RequestLoginCodeFailure` | `NetworkError` |
| `VerifyLoginCodeFailure` | `InvalidCode` |
| Any other `Exception` | `UnknownError` |

---

## Testing

```bash
dart test
```
