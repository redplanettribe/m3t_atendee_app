import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:m3t_attendee/features/register_for_event/bloc/bloc.dart';

final class RegisterForEventPage extends StatelessWidget {
  const RegisterForEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterForEventCubit(
        attendeeRepository: context.read<AttendeeRepository>(),
      ),
      child: const _RegisterForEventView(),
    );
  }
}

final class _RegisterForEventView extends StatelessWidget {
  const _RegisterForEventView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register for event'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<RegisterForEventCubit, RegisterForEventState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == RegisterForEventStatus.success,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("You're registered for the event."),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        },
        builder: (context, state) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Enter event code',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Use the 4-character code shared by the event organizer.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                ),
                const SizedBox(height: 32),
                _EventCodeField(),
                const SizedBox(height: 32),
                _SubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _EventCodeField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterForEventCubit, RegisterForEventState>(
      buildWhen: (previous, current) =>
          previous.eventCode != current.eventCode ||
          previous.status != current.status,
        builder: (context, state) {
        final hasError = state.errorMessage != null;
        return TextField(
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          maxLength: 4,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            labelText: 'Event code',
            hintText: 'e.g. ABCD',
            counterText: '',
            errorText: hasError ? state.errorMessage : null,
            border: const OutlineInputBorder(),
            filled: true,
          ),
          onChanged: (value) =>
              context.read<RegisterForEventCubit>().eventCodeChanged(value),
          onSubmitted: (_) => context.read<RegisterForEventCubit>().submit(),
        );
      },
    );
  }
}

final class _SubmitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterForEventCubit, RegisterForEventState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.eventCode != current.eventCode,
      builder: (context, state) {
        final isLoading = state.status == RegisterForEventStatus.loading;
        final canSubmit = state.eventCode.trim().length == 4 && !isLoading;
        return FilledButton(
          onPressed: canSubmit
              ? () => context.read<RegisterForEventCubit>().submit()
              : null,
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Register'),
        );
      },
    );
  }
}
