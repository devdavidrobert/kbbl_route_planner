// lib/domain/repositories/auth_repository.dart
import '../entities/user.dart';
import '../entities/auth_result.dart';

abstract class AuthRepository {
  Future<AuthResult> signInWithGoogle();
  Future<void> signOut();
  Future<User?> getCurrentUser();
}
