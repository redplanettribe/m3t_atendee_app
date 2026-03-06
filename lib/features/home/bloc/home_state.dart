part of 'home_cubit.dart';

/// Immutable state for the home (my registered events) feature.
final class HomeState extends Equatable {
  const HomeState({
    this.events = const [],
    this.loading = false,
    this.errorMessage,
  });

  final List<RegisteredEventEntity> events;
  final bool loading;
  final String? errorMessage;

  static const _sentinel = Object();

  HomeState copyWith({
    List<RegisteredEventEntity>? events,
    bool? loading,
    Object? errorMessage = _sentinel,
  }) {
    return HomeState(
      events: events ?? this.events,
      loading: loading ?? this.loading,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [events, loading, errorMessage];
}
