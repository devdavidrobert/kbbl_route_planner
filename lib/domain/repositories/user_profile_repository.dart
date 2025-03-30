// lib/domain/repositories/user_profile_repository.dart
import '../entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile?> getUserProfile(String email);
  Future<void> createUserProfile(UserProfile profile);
  Future<void> updateUserProfile(UserProfile profile);
}
