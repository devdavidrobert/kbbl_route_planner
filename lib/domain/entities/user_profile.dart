// lib/domain/entities/user_profile.dart
class UserProfile {
  final String userId;
  final String email;
  final String name;
  final String? region;
  final String? territory;
  final String? branch;

  UserProfile({
    required this.userId,
    required this.email,
    required this.name,
    this.region,
    this.territory,
    this.branch,
  });
}
