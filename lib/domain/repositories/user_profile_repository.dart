// lib/domain/repositories/user_profile_repository.dart
import 'package:dartz/dartz.dart';

import '../entities/user_profile.dart';
import '../core/failures.dart';

abstract class UserProfileRepository {
  Future<Either<Failure, UserProfile?>> getUserProfile(String email);
  Future<Either<Failure, void>> createUserProfile(UserProfile profile);
  Future<Either<Failure, void>> updateUserProfile(UserProfile profile);
}
