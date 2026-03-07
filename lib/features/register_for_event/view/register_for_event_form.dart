import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:m3t_attendee/features/register_for_event/bloc/bloc.dart';
import 'package:m3t_attendee/features/registered_events/cubit/registered_events_cubit.dart';

final class RegisterForEventForm extends StatelessWidget {
  const RegisterForEventForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register for event'),
      ),
      body: BlocConsumer<RegisterForEventCubit, RegisterForEventState>(
        listenWhen: (previous, current) =>
            previous.status != current.status && current.status == .success,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("You're registered for the event."),
              behavior: .floating,
            ),
          );
          unawaited(context.read<RegisteredEventsCubit>().refresh());
          context.pop();
        },
        builder: (context, state) {
          final cubit = context.read<RegisterForEventCubit>();
          final isLoading = state.status == .loading;
          final canSubmit = state.eventCode.length == 4 && !isLoading;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const .symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: .stretch,
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
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const _EventCodeField(),
                  const SizedBox(height: 32),
                  _SubmitButton(
                    onPressed: canSubmit ? cubit.submit : null,
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

final class _EventCodeField extends StatefulWidget {
  const _EventCodeField();

  @override
  State<_EventCodeField> createState() => _EventCodeFieldState();
}

final class _EventCodeFieldState extends State<_EventCodeField> {
  static String? _errorMessageSelector(RegisterForEventCubit cubit) =>
      cubit.state.errorMessage;

  late final RegisterForEventCubit _cubit;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<RegisterForEventCubit>();
    _controller = TextEditingController(text: _cubit.state.eventCode);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final errorMessage = context.select(_errorMessageSelector);
    return TextField(
      controller: _controller,
      autofocus: true,
      // textCapitalization is an IME hint only; _UpperCaseTextFormatter
      // enforces uppercase for all input paths (including paste/autofill).
      textCapitalization: .characters,
      maxLength: 4,
      autocorrect: false,
      enableSuggestions: false,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
        const _UpperCaseTextFormatter(),
      ],
      decoration: InputDecoration(
        labelText: 'Event code',
        hintText: 'e.g. ABCD',
        counterText: '',
        errorText: errorMessage,
        border: const OutlineInputBorder(),
        filled: true,
      ),
      onChanged: _cubit.eventCodeChanged,
      onSubmitted: (_) => _cubit.submit(),
    );
  }
}

final class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onPressed, required this.isLoading});

  /// Null disables the button; non-null enables it.
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      child: isLoading
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Register'),
    );
  }
}

/// Converts all typed/pasted characters to uppercase.
///
/// Works for every input path (keyboard, paste, autofill, accessibility),
/// unlike [TextCapitalization] which is an IME hint only.
final class _UpperCaseTextFormatter extends TextInputFormatter {
  const _UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}
