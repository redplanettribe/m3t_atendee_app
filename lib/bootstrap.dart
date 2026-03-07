import 'package:attendee_repository/attendee_repository.dart';
import 'package:auth_repository/auth_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:m3t_api/m3t_api.dart';
import 'package:m3t_attendee/app/app.dart';
import 'package:m3t_attendee/core/app_config.dart';
import 'package:m3t_attendee/infrastructure/flutter_secure_token_storage.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Hive init — must happen before any box is opened
  await Hive.initFlutter();
  Hive.registerAdapter(RegisteredEventHiveModelAdapter()); // generated class
  final registeredEventsBox = await Hive.openBox<RegisteredEventHiveModel>(
    HiveRegisteredEventsDataSource.boxName,
  );
  final localDataSource = HiveRegisteredEventsDataSource(
    box: registeredEventsBox,
  );

  // tokenStorage is created first so it can be passed as the token provider
  // to M3tApiClient — the same source of truth for both auth and API calls.
  const tokenStorage = FlutterSecureTokenStorage();
  final apiClient = M3tApiClient(
    tokenProvider: tokenStorage.read,
    baseUrl: AppConfig.baseUrl,
    objectStoreBaseUrl: Uri.parse(AppConfig.objectStoreUrl),
  );
  final authRepository = AuthRepositoryImpl(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );
  final attendeeRepository = AttendeeRepositoryImpl(
    apiClient: apiClient,
    localDataSource: localDataSource,
  );

  try {
    await authRepository.initialize();
  } on Object catch (error, stackTrace) {
    // Storage may be unavailable on first install or after device migration.
    // initialize() already defaults to unauthenticated on Exception internally;
    // this catches anything that escapes (e.g. platform Errors) so runApp()
    // is always reached.
    debugPrint('bootstrap: authRepository.initialize() failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  runApp(
    App(
      authRepository: authRepository,
      attendeeRepository: attendeeRepository,
    ),
  );
}
