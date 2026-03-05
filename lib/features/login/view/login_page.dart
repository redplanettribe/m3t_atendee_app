import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_attendee/features/login/login.dart';
import 'package:m3t_attendee/features/login/view/login_form.dart';

final class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => LoginBloc(authRepository: context.read()),
        child: const LoginForm(),
      ),
    );
  }
}
