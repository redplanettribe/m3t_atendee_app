# m3t_api

HTTP client and DTOs for the m3t Attendee backend. This package handles the network — it knows nothing about the domain.

---

## Usage

```dart
// tokenProvider is required — the client calls it on every authenticated request.
// baseUrl is optional; defaults to the Android emulator loopback for local dev.
final client = M3tApiClient(
  tokenProvider: () async => await secureStorage.read(),
  baseUrl: 'https://your-api-host.example.com', // optional, override via --dart-define
);

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
| `GetCurrentUserFailure` | Fetching current user's profile fails |
| `UpdateCurrentUserFailure` | Updating current user's profile fails |
| `RequestAvatarUploadFailure` | Requesting a presigned avatar upload URL fails |
| `UploadAvatarFailure` | Uploading avatar bytes to storage fails |
| `ConfirmAvatarFailure` | Confirming uploaded avatar with the backend fails |

These are transport-layer exceptions. `auth_repository` translates them into domain failures at the boundary.

---

## Testing

```bash
flutter test
```
