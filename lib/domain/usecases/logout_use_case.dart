// lib/domain/usecases/logout_use_case.dart
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> execute() async {
    await repository.signOut();
  }
}
