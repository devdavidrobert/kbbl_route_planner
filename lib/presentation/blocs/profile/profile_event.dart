// lib/presentation/blocs/profile/profile_event.dart
import '../../../domain/entities/user_profile.dart';

abstract class ProfileEvent {}

class UpdateProfileRequested extends ProfileEvent {
  final UserProfile profile;

  UpdateProfileRequested(this.profile);
}
