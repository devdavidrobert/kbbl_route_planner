// lib/presentation/blocs/auth/auth_event.dart
import '../../../domain/entities/user.dart';
import '../../../domain/entities/user_profile.dart';

abstract class AuthEvent {}

class AuthLoginRequested extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}

class AuthProfileCreated extends AuthEvent {
  final User user;
  final UserProfile profile;

  AuthProfileCreated(this.user, this.profile);
}

class AuthProfileUpdated extends AuthEvent {
  final User user;
  final UserProfile profile;

  AuthProfileUpdated(this.user, this.profile);
}

class SignInWithGooglePressed extends AuthEvent {}

class SignOutPressed extends AuthEvent {}
