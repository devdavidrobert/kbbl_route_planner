// lib/domain/usecases/create_profile_use_case.dart
import '../entities/user_profile.dart';
import '../repositories/user_profile_repository.dart';

class CreateProfileUseCase {
  final UserProfileRepository repository;

  CreateProfileUseCase(this.repository);

  Future<void> execute(UserProfile profile) async {
    await repository.createUserProfile(profile);
  }
}
