/// Compile-time configuration injected via `--dart-define`.
///
/// Usage:
/// ```sh
/// fvm flutter run --dart-define=M3T_API_URL=https://api.example.com
/// fvm flutter build apk --dart-define=M3T_API_URL=https://api.example.com
/// fvm flutter build ios --dart-define=M3T_API_URL=https://api.example.com
/// ```
abstract final class AppConfig {
  /// The base URL for the m3t backend API.
  ///
  /// Defaults to the Android emulator loopback address for local development.
  static const baseUrl = String.fromEnvironment(
    'M3T_API_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  /// The base URL for the object store (MinIO/S3) used by presigned upload URLs.
  ///
  /// Defaults to the Android emulator loopback address for local development.
  /// This is used to reach your host machine from the Android emulator.
  static const objectStoreUrl = String.fromEnvironment(
    'OBJECT_STORE_URL',
    defaultValue: 'http://10.0.2.2:9000',
  );
}
