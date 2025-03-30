// lib/presentation/blocs/auth/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import '../../../domain/usecases/login_use_case.dart';
import '../../../domain/usecases/logout_use_case.dart';
import '../../../domain/usecases/check_profile_use_case.dart';
import '../../../domain/usecases/create_profile_use_case.dart';
import '../../../domain/usecases/update_profile_use_case.dart';
import '../../../domain/core/failures.dart' as failures;
import '../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckProfileUseCase checkProfileUseCase;
  final CreateProfileUseCase createProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final AuthRepository _authRepository;
  final _logger = Logger('AuthBloc');

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.checkProfileUseCase,
    required this.createProfileUseCase,
    required this.updateProfileUseCase,
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(AuthInitial()) {
    on<SignInWithGooglePressed>((event, emit) async {
      emit(AuthLoading());
      try {
        _logger.info('Starting login process');
        
        // First, sign in with Google
        final authResult = await _authRepository.signInWithGoogle();
        
        if (authResult.needsProfile) {
          emit(AuthNeedsProfile(user: authResult.user));
        } else if (authResult.profile != null) {
          emit(AuthSuccess(
            user: authResult.user,
            profile: authResult.profile!,
          ));
        } else {
          emit(AuthFailure(message: 'Profile data is missing'));
        }
      } catch (e) {
        _logger.severe('Login error: $e');
        if (e.toString().contains('network_error') || 
            e.toString().contains('socket') ||
            e.toString().contains('NetworkException')) {
          emit(AuthFailure(message: 'Unable to sign in. Please check your internet connection.'));
        } else if (e.toString().contains('popup_closed_by_user') || 
                   e.toString().contains('cancelled') ||
                   e.toString().contains('user_cancelled')) {
          emit(AuthFailure(message: 'Sign in was cancelled. Please try again.'));
        } else if (e.toString().contains('account_exists_with_different_credential')) {
          emit(AuthFailure(message: 'An account already exists with a different sign-in method.'));
        } else if (e.toString().contains('timed out')) {
          emit(AuthFailure(message: 'Sign in timed out. Please try again.'));
        } else {
          emit(AuthFailure(message: e.toString()));
        }
      }
    });

    on<SignOutPressed>((event, emit) async {
      emit(AuthLoading());
      try {
        _logger.info('Starting logout process');
        await logoutUseCase.execute();
        _logger.info('Logout successful');
        emit(AuthInitial());
      } catch (e) {
        _logger.severe('Logout error: $e');
        emit(AuthFailure(message: e.toString()));
      }
    });

    on<AuthProfileCreated>((event, emit) async {
      emit(AuthLoading());
      try {
        _logger.info('Creating user profile for: ${event.user.email}');
        final result = await createProfileUseCase.execute(event.profile);
        
        await result.fold(
          (failure) async {
            _logger.severe('Failed to create profile: ${failure.message}');
            if (failure is failures.NetworkFailure) {
              emit(AuthFailure(message: 'No internet connection. Please check your connection and try again.'));
            } else if (failure is failures.ServerFailure) {
              emit(AuthFailure(message: 'Server error. Please try again later.'));
            } else {
              emit(AuthFailure(message: failure.message));
            }
          },
          (_) async {
            _logger.info('Profile created successfully');
            emit(AuthSuccess(user: event.user, profile: event.profile));
          },
        );
      } catch (e) {
        _logger.severe('Profile creation error: $e');
        emit(AuthFailure(message: 'Failed to create profile. Please try again.'));
      }
    });

    on<AuthProfileUpdated>((event, emit) async {
      emit(AuthLoading());
      try {
        _logger.info('Updating user profile for: ${event.user.email}');
        // Check if the profile exists by fetching it
        final profileResult = await checkProfileUseCase.execute(event.profile.email);
        
        await profileResult.fold(
          (failure) async {
            _logger.severe('Failed to check profile: ${failure.message}');
            if (failure is failures.NetworkFailure) {
              emit(AuthFailure(message: 'No internet connection. Please check your connection and try again.'));
            } else if (failure is failures.ServerFailure) {
              emit(AuthFailure(message: 'Server error. Please try again later.'));
            } else {
              emit(AuthFailure(message: failure.message));
            }
          },
          (existingProfile) async {
            if (existingProfile == null) {
              _logger.info('Profile not found, creating new profile');
              final createResult = await createProfileUseCase.execute(event.profile);
              await createResult.fold(
                (failure) async {
                  _logger.severe('Failed to create profile: ${failure.message}');
                  emit(AuthFailure(message: failure.message));
                },
                (_) async {
                  _logger.info('Profile created successfully');
                  emit(AuthSuccess(user: event.user, profile: event.profile));
                },
              );
            } else {
              _logger.info('Profile found, updating existing profile');
              final updateResult = await updateProfileUseCase.execute(event.profile);
              await updateResult.fold(
                (failure) async {
                  _logger.severe('Failed to update profile: ${failure.message}');
                  emit(AuthFailure(message: failure.message));
                },
                (_) async {
                  _logger.info('Profile update successful');
                  emit(AuthSuccess(user: event.user, profile: event.profile));
                },
              );
            }
          },
        );
      } catch (e) {
        _logger.severe('Profile update error: $e');
        emit(AuthFailure(message: 'Failed to update profile. Please try again.'));
      }
    });
  }
}
