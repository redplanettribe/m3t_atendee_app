import 'package:auth_repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:m3t_api/m3t_api.dart';
import 'package:m3t_attendee/app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  const secureStorage = FlutterSecureStorage();

  final apiClient = M3tApiClient(
    tokenProvider: () => secureStorage.read(key: AuthRepository.tokenKey),
  );

  final authRepository = AuthRepository(
    apiClient: apiClient,
    secureStorage: secureStorage,
  );

  runApp(App(authRepository: authRepository));
}
