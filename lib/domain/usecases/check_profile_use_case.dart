// lib/domain/usecases/check_profile_use_case.dart
import '../entities/user_profile.dart';
import '../repositories/user_profile_repository.dart';

class CheckProfileUseCase {
  final UserProfileRepository repository;

  CheckProfileUseCase(this.repository);

  Future<UserProfile?> execute(String email) async {
    return await repository.getUserProfile(email);
  }
}
