# m3t_api

HTTP client and DTOs for the m3t Attendee backend. This package handles the network — it knows nothing about the domain.

---

## Usage

```dart
final client = M3tApiClient(baseUrl: 'https://api.example.com');

await client.requestLoginCode('user@example.com');

final response = await client.verifyLoginCode(
  email: 'user@example.com',
  code: '123456',
);
// response.token, response.user
```

---

## Exceptions

| Exception | When |
|---|---|
| `RequestLoginCodeFailure` | Login-code request fails |
| `VerifyLoginCodeFailure` | Code verification fails |

These are transport-layer exceptions. `auth_repository` translates them into domain failures at the boundary.

---

## Testing

```bash
flutter test
```
