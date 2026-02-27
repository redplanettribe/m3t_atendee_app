import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_attendee/login/login.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (previous, current) =>
          previous.status != current.status,
      listener: (context, state) {
        if (state.status == LoginStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
      },
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: BlocBuilder<LoginBloc, LoginState>(
              builder: (context, state) {
                return switch (state.step) {
                  LoginStep.emailEntry => const _EmailStep(),
                  LoginStep.codeVerification =>
                    const _CodeVerificationStep(),
                };
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailStep extends StatefulWidget {
  const _EmailStep();

  @override
  State<_EmailStep> createState() => _EmailStepState();
}

class _EmailStepState extends State<_EmailStep> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(
      text: context.read<LoginBloc>().state.email,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = context.select(
      (LoginBloc bloc) => bloc.state.status == LoginStatus.loading,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your email to receive a login code.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _emailController,
          onChanged: (value) =>
              context.read<LoginBloc>().add(LoginEmailChanged(value)),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'you@example.com',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) {
            if (!isLoading) {
              context
                  .read<LoginBloc>()
                  .add(const LoginCodeRequested());
            }
          },
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: isLoading
              ? null
              : () => context
                  .read<LoginBloc>()
                  .add(const LoginCodeRequested()),
          child: isLoading
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Send Code'),
        ),
      ],
    );
  }
}

class _CodeVerificationStep extends StatefulWidget {
  const _CodeVerificationStep();

  @override
  State<_CodeVerificationStep> createState() =>
      _CodeVerificationStepState();
}

class _CodeVerificationStepState extends State<_CodeVerificationStep> {
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(
      text: context.read<LoginBloc>().state.code,
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<LoginBloc>().state;
    final isLoading = state.status == LoginStatus.loading;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.mark_email_read_outlined,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'Check your email',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'We sent a code to ${state.email}',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _codeController,
          onChanged: (value) =>
              context.read<LoginBloc>().add(LoginCodeChanged(value)),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            letterSpacing: 8,
          ),
          decoration: const InputDecoration(
            labelText: 'Verification Code',
            hintText: '000000',
            prefixIcon: Icon(Icons.pin_outlined),
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) {
            if (!isLoading) {
              context
                  .read<LoginBloc>()
                  .add(const LoginCodeSubmitted());
            }
          },
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: isLoading
              ? null
              : () => context
                  .read<LoginBloc>()
                  .add(const LoginCodeSubmitted()),
          child: isLoading
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Verify'),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: isLoading
              ? null
              : () => context
                  .read<LoginBloc>()
                  .add(const LoginStepBackToEmail()),
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text('Use a different email'),
        ),
      ],
    );
  }
}
