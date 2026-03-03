// Re-export the abstract interface so consumers can type against AuthRepository
// without importing the domain package directly.
export 'package:domain/domain.dart' show AuthRepository;

export 'src/auth_repository.dart';
export 'src/ports/token_storage.dart';
