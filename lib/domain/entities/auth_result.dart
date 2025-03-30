// lib/domain/entities/auth_result.dart
import 'user.dart';
import 'user_profile.dart';

class AuthResult {
  final User user;
  final UserProfile? profile;
  final bool needsProfile;

  AuthResult({
    required this.user,
    required this.profile,
    required this.needsProfile,
  });
} 