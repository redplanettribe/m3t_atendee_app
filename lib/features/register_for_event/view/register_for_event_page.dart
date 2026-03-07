import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_attendee/features/register_for_event/bloc/bloc.dart';
import 'package:m3t_attendee/features/register_for_event/view/register_for_event_form.dart';

final class RegisterForEventPage extends StatelessWidget {
  const RegisterForEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterForEventCubit(
        attendeeRepository: context.read<AttendeeRepository>(),
      ),
      child: const RegisterForEventForm(),
    );
  }
}
