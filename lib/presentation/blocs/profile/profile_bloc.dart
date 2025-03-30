// lib/presentation/blocs/profile/profile_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import '../../../domain/usecases/create_profile_use_case.dart';
import '../../../domain/usecases/update_profile_use_case.dart';
import '../../../domain/usecases/check_profile_use_case.dart';
import '../../../domain/core/failures.dart' as failures;
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final CreateProfileUseCase createProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final CheckProfileUseCase checkProfileUseCase;
  final _logger = Logger('ProfileBloc');

  ProfileBloc({
    required this.createProfileUseCase,
    required this.updateProfileUseCase,
    required this.checkProfileUseCase,
  }) : super(ProfileInitial()) {
    on<CreateProfileRequested>(_onCreateProfileRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<CheckProfileRequested>(_onCheckProfileRequested);
  }

  Future<void> _onCreateProfileRequested(
    CreateProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      _logger.info('Creating profile for user: ${event.user.email}');
      final result = await createProfileUseCase.execute(event.profile);
      
      await result.fold(
        (failure) async {
          _logger.severe('Failed to create profile: ${failure.message}');
          if (failure is failures.NetworkFailure) {
            emit(ProfileFailure(message: 'No internet connection. Please check your connection and try again.'));
          } else if (failure is failures.ServerFailure) {
            emit(ProfileFailure(message: 'Server error. Please try again later.'));
          } else {
            emit(ProfileFailure(message: failure.message));
          }
        },
        (_) async {
          _logger.info('Profile created successfully');
          emit(ProfileSuccess(profile: event.profile));
        },
      );
    } catch (e) {
      _logger.severe('Profile creation error: $e');
      emit(ProfileFailure(message: 'Failed to create profile. Please try again.'));
    }
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      _logger.info('Updating profile for user: ${event.user.email}');
      final result = await updateProfileUseCase.execute(event.profile);
      
      await result.fold(
        (failure) async {
          _logger.severe('Failed to update profile: ${failure.message}');
          if (failure is failures.NetworkFailure) {
            emit(ProfileFailure(message: 'No internet connection. Please check your connection and try again.'));
          } else if (failure is failures.ServerFailure) {
            emit(ProfileFailure(message: 'Server error. Please try again later.'));
          } else {
            emit(ProfileFailure(message: failure.message));
          }
        },
        (_) async {
          _logger.info('Profile updated successfully');
          emit(ProfileSuccess(profile: event.profile));
        },
      );
    } catch (e) {
      _logger.severe('Profile update error: $e');
      emit(ProfileFailure(message: 'Failed to update profile. Please try again.'));
    }
  }

  Future<void> _onCheckProfileRequested(
    CheckProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      _logger.info('Checking profile for user: ${event.email}');
      final result = await checkProfileUseCase.execute(event.email);
      
      await result.fold(
        (failure) async {
          _logger.severe('Failed to check profile: ${failure.message}');
          if (failure is failures.NetworkFailure) {
            emit(ProfileFailure(message: 'No internet connection. Please check your connection and try again.'));
          } else if (failure is failures.ServerFailure) {
            emit(ProfileFailure(message: 'Server error. Please try again later.'));
          } else {
            emit(ProfileFailure(message: failure.message));
          }
        },
        (profile) async {
          if (profile == null) {
            _logger.info('Profile not found');
            emit(ProfileNotFound());
          } else {
            _logger.info('Profile found');
            emit(ProfileSuccess(profile: profile));
          }
        },
      );
    } catch (e) {
      _logger.severe('Profile check error: $e');
      emit(ProfileFailure(message: 'Failed to check profile. Please try again.'));
    }
  }
}
