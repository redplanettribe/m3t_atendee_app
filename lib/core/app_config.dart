/// Compile-time configuration injected via `--dart-define`.
///
/// Usage:
/// ```sh
/// flutter run --dart-define=BASE_URL=https://api.example.com
/// flutter build apk --dart-define=BASE_URL=https://api.example.com
/// flutter build ios --dart-define=BASE_URL=https://api.example.com
/// ```
abstract final class AppConfig {
  /// The base URL for the m3t backend API.
  ///
  /// Defaults to the Android emulator loopback address for local development.
  static const baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );
}
