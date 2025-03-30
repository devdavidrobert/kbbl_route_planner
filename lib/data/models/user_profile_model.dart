// lib/data/models/user_profile_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_profile.dart';

part 'user_profile_model.g.dart';

@JsonSerializable()
class UserProfileModel extends UserProfile {
  UserProfileModel({
    required String userId,
    required String email,
    required String name,
    String? region,
    String? territory,
    String? branch,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          userId: userId,
          email: email,
          name: name,
          region: region,
          territory: territory,
          branch: branch,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileModelToJson(this);

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      userId: entity.userId,
      email: entity.email,
      name: entity.name,
      region: entity.region,
      territory: entity.territory,
      branch: entity.branch,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // Since this class extends UserProfile, it can be used directly as an entity
  UserProfile toEntity() => this;

  @override
  UserProfileModel copyWith({
    String? userId,
    String? email,
    String? name,
    String? region,
    String? territory,
    String? branch,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
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
