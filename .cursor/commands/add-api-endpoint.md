# Add API Endpoint

## Overview

Add a new backend API endpoint to the app: extend `M3tApiClient` in `packages/m3t_api`, add a typed exception, add or reuse models, and call it from a repository. Follow the m3t-api-usage skill and dart-model-from-json rule. Use `docs/api/swagger.json` as the source of truth for paths, parameters, and response shapes.

## Steps

1. **Check the API spec**
   - Open `docs/api/swagger.json` and find the path, HTTP method, parameters (path, query, body), and response schema. Note whether the endpoint uses Bearer auth (`security: BearerAuth`).

2. **Add or reuse models**
   - If the response has a new shape, add a model in `packages/m3t_api/lib/src/models/` following project conventions: `final class`, `Equatable`, `@JsonSerializable(fieldRename: FieldRename.snake)`, `part '*.g.dart'`, `fromJson`/`toJson`. Run `dart run build_runner build --delete-conflicting-outputs` in the package. Export from `models/models.dart`.

3. **Add exception**
   - In `packages/m3t_api/lib/src/exceptions.dart`, add a new `final class` (e.g. `GetEventsFailure`) with a `message` field, implementing `Exception`. Export if needed.

4. **Add client method**
   - In `packages/m3t_api/lib/src/m3t_api_client.dart`, add a method that builds the URI with `_uri(path)`, uses `_jsonHeaders` or `await _authHeaders()` for auth, sends the request with `_httpClient`, parses JSON with `_decodeJson`, checks for `error` in the envelope and throws the new exception, and returns the model from `data`.

5. **Expose via repository**
   - If a new repository is needed: add an abstract method on the domain interface in `packages/domain` and implement it in the data package (e.g. `auth_repository` or a new package) by calling the new client method. Map the new client exception to a domain failure. If the endpoint fits an existing repository, add the method there and implement it.

6. **Use from BLoC/Cubit**
   - In the presentation layer, the BLoC/Cubit already depends on the repository interface; call the new repository method and handle domain failures (e.g. emit error state with user-facing message).

## Checklist

- [ ] Path, verb, and response shape confirmed from `docs/api/swagger.json`
- [ ] New model(s) in `packages/m3t_api/lib/src/models/` and build_runner run
- [ ] New exception in `packages/m3t_api/lib/src/exceptions.dart`
- [ ] New method on `M3tApiClient` with envelope handling and typed exception
- [ ] Repository method (domain interface + implementation) that calls client and maps exceptions to domain failures
- [ ] BLoC/Cubit uses repository only (no direct client use)
