/// Temporal classification for event scheduling.
///
/// Represents the honest relationship between an event's date range and
/// a reference date.
enum EventTimelineBucket {
  /// Event date range includes the reference date.
  current,

  /// Event starts after the reference date.
  upcoming,

  /// Event ended before the reference date.
  past,
}
