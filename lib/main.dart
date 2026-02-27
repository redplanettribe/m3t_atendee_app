import 'package:auth_repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:m3t_api/m3t_api.dart';
import 'package:m3t_attendee/app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = M3tApiClient();
  final authRepository = AuthRepository(apiClient: apiClient);

  runApp(App(authRepository: authRepository));
}
