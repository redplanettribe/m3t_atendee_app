part of 'register_for_event_cubit.dart';

enum RegisterForEventStatus { initial, loading, success, failure }

final class RegisterForEventState extends Equatable {
  const RegisterForEventState({
    this.eventCode = '',
    this.status = RegisterForEventStatus.initial,
    this.errorMessage,
  });

  final String eventCode;
  final RegisterForEventStatus status;
  final String? errorMessage;

  static const _sentinel = Object();

  RegisterForEventState copyWith({
    String? eventCode,
    RegisterForEventStatus? status,
    Object? errorMessage = _sentinel,
  }) {
    return RegisterForEventState(
      eventCode: eventCode ?? this.eventCode,
      status: status ?? this.status,
      errorMessage:
          errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [eventCode, status, errorMessage];
}
