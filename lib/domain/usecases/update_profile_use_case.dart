// lib/domain/usecases/update_profile_use_case.dart
import '../entities/user_profile.dart';
import '../repositories/user_profile_repository.dart';

class UpdateProfileUseCase {
  final UserProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<void> execute(UserProfile profile) async {
    await repository.updateUserProfile(profile);
  }
}
