import 'package:domain/domain.dart';

/// Contract for the on-device cache of the current user's registered events.
///
/// Implementations persist a snapshot of [RegisteredEventEntity] objects so
/// the app can render stale data immediately on launch, before the first
/// successful network response arrives.
///
/// ### Consistency model
/// The cache is always written as a **full replacement** — [write] overwrites
/// whatever was stored before. Partial updates are intentionally unsupported
/// to avoid drift between the cached list and the server's source of truth.
abstract interface class RegisteredEventsLocalDataSource {
  /// Returns the currently cached events, or an empty list if the cache is
  /// cold (never written) or has been explicitly [clear]ed.
  ///
  /// This is a synchronous read; implementations are expected to keep the
  /// dataset in memory (e.g. via an open Hive box).
  List<RegisteredEventEntity> read();

  /// Replaces the entire cached dataset with [events].
  ///
  /// Called after every successful network fetch to keep the cache fresh.
  /// Throws if the underlying storage operation fails.
  Future<void> write(List<RegisteredEventEntity> events);

  /// Removes all cached events.
  ///
  /// Should be called on sign-out to prevent one user's data from leaking
  /// to the next session on the same device.
  Future<void> clear();
}
