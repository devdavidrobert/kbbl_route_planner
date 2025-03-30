// lib/domain/usecases/login_use_case.dart
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<User> execute() async {
    return await repository.signInWithGoogle();
  }
}
