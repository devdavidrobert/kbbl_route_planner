// lib/domain/entities/user_profile.dart
class UserProfile {
  final String userId;
  final String email;
  final String name;
  final String? region;
  final String? territory;
  final String? branch;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.userId,
    required this.email,
    required this.name,
    this.region,
    this.territory,
    this.branch,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isComplete => 
    region != null && 
    territory != null && 
    branch != null;

  UserProfile copyWith({
    String? userId,
    String? email,
    String? name,
    String? region,
    String? territory,
    String? branch,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      region: region ?? this.region,
      territory: territory ?? this.territory,
      branch: branch ?? this.branch,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
