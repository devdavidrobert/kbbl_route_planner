// lib/domain/usecases/create_profile_use_case.dart
import 'package:dartz/dartz.dart';
import '../entities/user_profile.dart';
import '../repositories/user_profile_repository.dart';
import '../core/failures.dart';

class CreateProfileUseCase {
  final UserProfileRepository repository;

  CreateProfileUseCase(this.repository);

  Future<Either<Failure, void>> execute(UserProfile profile) async {
    return await repository.createUserProfile(profile);
  }
}
