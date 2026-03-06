---
name: m3t-api-usage
description: How to call and use the backend API via packages/m3t_api — client construction, endpoints, response envelope, typed exceptions, adding new endpoints. Use when calling the API, adding endpoints, or wiring a repository to the API.
---

# m3t_api — Backend API Usage

## When to Use

- Calling the backend API from the app.
- Adding a new API endpoint or wiring a repository to the client.
- Handling API errors or response shapes.

## Instructions

### 1. Where the client lives

- `M3tApiClient` lives in `packages/m3t_api`. The app does **not** call it from UI or BLoC. It is used only inside repository implementations (e.g. `AuthRepositoryImpl` in `packages/auth_repository`). BLoCs and widgets depend on the domain `AuthRepository` interface and get it via `context.read<AuthRepository>()`.

### 2. Construction

- In `lib/bootstrap.dart`, the client is built with:
  - **tokenProvider:** Required for authenticated requests (e.g. `tokenStorage.read`). The client calls it on each request that needs auth.
  - **baseUrl:** Optional; defaults to Android emulator loopback (`http://10.0.2.2:8080`). Override for other environments (e.g. via `--dart-define` or `AppConfig.baseUrl`).
- Optional: `http.Client` for testing or custom behavior.

### 3. Available methods

| Method | Returns | Auth |
|--------|---------|------|
| `requestLoginCode(String email)` | `Future<void>` | No |
| `verifyLoginCode({required email, required code})` | `Future<LoginResponse>` | No |
| `getCurrentUser()` | `Future<User>` | Yes |
| `updateCurrentUser({String? name, String? lastName})` | `Future<User>` | Yes |
| `requestAvatarUploadUrl()` | `Future<(Uri uploadUrl, String key)>` | Yes |
| `uploadAvatarBytes({required uploadUrl, bytes, contentType})` | `Future<void>` | No (upload to storage) |
| `confirmAvatar({required String key})` | `Future<User>` | Yes |

### 4. Response envelope

- The backend returns JSON with optional `data` and `error` fields. On success the client parses `data` and returns the model (e.g. `User`, `LoginResponse`). On error it throws a **typed exception** with a `message` (from `error` when present).

### 5. Typed exceptions

- One exception per endpoint. All have a `message` field. See `packages/m3t_api/lib/src/exceptions.dart`:
  - `RequestLoginCodeFailure`, `VerifyLoginCodeFailure`, `GetCurrentUserFailure`, `UpdateCurrentUserFailure`, `RequestAvatarUploadFailure`, `UploadAvatarFailure`, `ConfirmAvatarFailure`.
- These are transport-layer exceptions. The **repository** (e.g. `AuthRepositoryImpl`) catches them and maps them to domain failures (e.g. `InvalidCode`, `NetworkError`, `UnknownError`) before exposing to BLoCs.

### 6. API specification

- The backend API is documented in **`docs/api/swagger.json`** (OpenAPI/Swagger 2.0). Use it to see paths, parameters, request/response schemas, and which endpoints require Bearer auth. When adding or changing client methods, align with the spec.

### 7. Adding a new endpoint

1. Check **`docs/api/swagger.json`** for the path, verb, parameters, and response schema.
2. Add a method on `M3tApiClient` (path, HTTP verb, body, headers).
3. Add a dedicated exception class in `exceptions.dart` (e.g. `MyNewEndpointFailure`).
4. Parse the response: check status code, then `data`/`error` envelope; return a model from `data` or throw the exception with `error.message`.
5. If the response model is new, add it in `packages/m3t_api/lib/src/models/` (see dart-model-from-json skill) and run build_runner.
6. Call the new client method from the repository; catch the new exception and map to a domain failure.

## References

- `docs/api/swagger.json` — backend API specification (paths, schemas, auth)
- `packages/m3t_api/README.md` — usage summary and exception table
- `packages/m3t_api/lib/src/m3t_api_client.dart` — client implementation
- `packages/m3t_api/lib/src/exceptions.dart` — exception types
- `packages/auth_repository/lib/src/auth_repository.dart` — example of calling the client and mapping exceptions to domain failures
- `lib/bootstrap.dart` — how the client is constructed and passed to the repository
