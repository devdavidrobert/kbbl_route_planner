// lib/presentation/blocs/auth/auth_state.dart
import '../../../domain/entities/user.dart';
import '../../../domain/entities/user_profile.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLoggedOut extends AuthState {}

class AuthProfileComplete extends AuthState {
  final User user;
  final UserProfile profile;

  AuthProfileComplete({required this.user, required this.profile});
}

class AuthProfileIncomplete extends AuthState {
  final User user;
  final UserProfile? profile;

  AuthProfileIncomplete({required this.user, this.profile});
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}
