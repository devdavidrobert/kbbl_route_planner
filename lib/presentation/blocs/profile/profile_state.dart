// lib/presentation/blocs/profile/profile_state.dart
import '../../../domain/entities/user_profile.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileSuccess extends ProfileState {
  final UserProfile profile;

  ProfileSuccess({required this.profile});
}

class ProfileNotFound extends ProfileState {}

class ProfileFailure extends ProfileState {
  final String message;

  ProfileFailure({required this.message});
}
