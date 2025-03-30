// lib/presentation/blocs/profile/profile_event.dart
import '../../../domain/entities/user.dart';
import '../../../domain/entities/user_profile.dart';

abstract class ProfileEvent {}

class CreateProfileRequested extends ProfileEvent {
  final User user;
  final UserProfile profile;

  CreateProfileRequested(this.user, this.profile);
}

class UpdateProfileRequested extends ProfileEvent {
  final User user;
  final UserProfile profile;

  UpdateProfileRequested(this.user, this.profile);
}

class CheckProfileRequested extends ProfileEvent {
  final String email;

  CheckProfileRequested(this.email);
}
