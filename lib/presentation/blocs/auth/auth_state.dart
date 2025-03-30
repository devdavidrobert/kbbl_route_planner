// lib/presentation/blocs/auth/auth_state.dart
import '../../../domain/entities/user.dart';
import '../../../domain/entities/user_profile.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;
  final UserProfile profile;

  AuthSuccess({required this.user, required this.profile});
}

class AuthNeedsProfile extends AuthState {
  final User user;

  AuthNeedsProfile({required this.user});
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure({required this.message});
}
