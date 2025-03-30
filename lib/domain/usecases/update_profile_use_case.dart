// lib/domain/usecases/update_profile_use_case.dart
import 'package:dartz/dartz.dart';
import '../entities/user_profile.dart';
import '../repositories/user_profile_repository.dart';
import '../core/failures.dart';

class UpdateProfileUseCase {
  final UserProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, void>> execute(UserProfile profile) async {
    return await repository.updateUserProfile(profile);
  }
}
