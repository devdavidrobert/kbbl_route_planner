// lib/data/models/user_profile_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_profile.dart';

part 'user_profile_model.g.dart';

@JsonSerializable()
class UserProfileModel {
  final String userId;
  final String email;
  final String name;
  final String? region;
  final String? territory;
  final String? branch;

  UserProfileModel({
    required this.userId,
    required this.email,
    required this.name,
    this.region,
    this.territory,
    this.branch,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileModelToJson(this);

  UserProfile toEntity() => UserProfile(
        userId: userId,
        email: email,
        name: name,
        region: region,
        territory: territory,
        branch: branch,
      );

  static UserProfileModel fromEntity(UserProfile profile) => UserProfileModel(
        userId: profile.userId,
        email: profile.email,
        name: profile.name,
        region: profile.region,
        territory: profile.territory,
        branch: profile.branch,
      );
}
