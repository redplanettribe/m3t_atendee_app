---
name: dart-model-from-json
description: Generate or edit Dart API/DTO models from JSON using json_serializable, Equatable, snake_case, and copyWith; run build_runner after changes. Use when adding or editing API DTOs or JSON models.
---

# Dart API Models from JSON

## When to Use

- Creating or changing data models that map to JSON (e.g. API DTOs in `m3t_api`).
- Adding a new request/response type for the backend API.

## Instructions

1. **Location:** API models go in `packages/m3t_api/lib/src/models/`. One file per model; barrel in `models/models.dart`.
2. **Class:** `final class <Name> extends Equatable` (Dart 3 style). Use `part '<name>.g.dart';` and generate with `dart run build_runner build --delete-conflicting-outputs`.
3. **Serialization:** Use `@JsonSerializable(fieldRename: FieldRename.snake)` so Dart stays camelCase and JSON keys are snake_case. Avoid per-field `@JsonKey` unless you need a custom rename or converter.
4. **Constructors:** Prefer `const` and `required` for non-nullable; optional for nullable.
5. **fromJson / toJson:** `factory ModelName.fromJson(Map<String, dynamic> json) => _$ModelNameFromJson(json);` and `Map<String, dynamic> toJson() => _$ModelNameToJson(this);`.
6. **Equatable:** Override `List<Object?> get props` with all fields.
7. **copyWith:** Manual implementation. For nullable fields use a sentinel if you need "omit" vs "set to null" (see bloc-conventions for pattern); otherwise `field: field ?? this.field`.
8. **After editing:** Run `dart run build_runner build --delete-conflicting-outputs` from package or repo root; commit `.g.dart` files.
9. **Dependencies:** In `packages/m3t_api/pubspec.yaml` — `json_annotation`, `equatable`; dev: `build_runner`, `json_serializable`. No Flutter.

## References

- `packages/m3t_api/lib/src/models/user.dart`
- `packages/m3t_api/lib/src/models/login_response.dart`
- `.cursor/rules/dart-model-from-json.mdc` — full rule
