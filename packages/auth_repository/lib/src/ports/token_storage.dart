/// Port: defines the contract for reading, writing, and deleting the
/// persisted auth token.
///
/// Implementations live outside this package (e.g. a Flutter adapter backed by
/// `flutter_secure_storage`).
abstract interface class TokenStorage {
  /// Returns the stored token, or `null` if none is present.
  Future<String?> read();

  /// Persists [token].
  Future<void> write(String token);

  /// Removes the stored token.
  Future<void> delete();
}
