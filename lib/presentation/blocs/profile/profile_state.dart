// lib/presentation/blocs/profile/profile_state.dart
import '../../../domain/entities/user_profile.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileUpdated extends ProfileState {
  final UserProfile profile;

  ProfileUpdated(this.profile);
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}
