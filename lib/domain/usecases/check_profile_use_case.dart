// lib/domain/usecases/check_profile_use_case.dart
import 'package:dartz/dartz.dart';
import '../entities/user_profile.dart';
import '../repositories/user_profile_repository.dart';
import '../core/failures.dart';

class CheckProfileUseCase {
  final UserProfileRepository repository;

  CheckProfileUseCase(this.repository);

  Future<Either<Failure, UserProfile?>> execute(String email) async {
    return await repository.getUserProfile(email);
  }
}
