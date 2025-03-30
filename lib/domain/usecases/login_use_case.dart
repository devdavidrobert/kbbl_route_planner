// lib/domain/usecases/login_use_case.dart
import 'package:kbbl_route_planner/domain/entities/auth_result.dart';

import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthResult> execute() async {
    return await repository.signInWithGoogle();
  }
}
