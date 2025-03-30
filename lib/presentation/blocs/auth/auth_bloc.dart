// lib/presentation/blocs/auth/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/login_use_case.dart';
import '../../../domain/usecases/logout_use_case.dart';
import '../../../domain/usecases/check_profile_use_case.dart';
import '../../../domain/usecases/create_profile_use_case.dart';
import '../../../domain/usecases/update_profile_use_case.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckProfileUseCase checkProfileUseCase;
  final CreateProfileUseCase createProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.checkProfileUseCase,
    required this.createProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(AuthInitial()) {
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        print('AuthBloc: Starting login process...');
        final user = await loginUseCase.execute();
        print('AuthBloc: User logged in: ${user.id}');
        final profile = await checkProfileUseCase.execute(user.email);
        print(
            'AuthBloc: Profile check result: ${profile?.toString() ?? "null"}');
        if (profile == null) {
          emit(AuthProfileIncomplete(user: user, profile: null));
        } else if (profile.region == null || profile.territory == null) {
          emit(AuthProfileIncomplete(user: user, profile: profile));
        } else {
          emit(AuthProfileComplete(user: user, profile: profile));
        }
      } catch (e) {
        print('AuthBloc: Login failed: $e');
        emit(AuthError(e.toString()));
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await logoutUseCase.execute();
        emit(AuthLoggedOut());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AuthProfileCreated>((event, emit) async {
      emit(AuthLoading());
      try {
        await createProfileUseCase.execute(event.profile);
        emit(AuthProfileComplete(user: event.user, profile: event.profile));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AuthProfileUpdated>((event, emit) async {
      emit(AuthLoading());
      try {
        // Check if the profile exists by fetching it
        final existingProfile =
            await checkProfileUseCase.execute(event.profile.email);
        if (existingProfile == null) {
          print('AuthBloc: Creating new profile for user: ${event.user.id}');
          await createProfileUseCase.execute(event.profile);
        } else {
          print(
              'AuthBloc: Updating existing profile for user: ${event.user.id}');
          await updateProfileUseCase.execute(event.profile);
        }
        print(
            'AuthBloc: Emitting AuthProfileComplete for user: ${event.user.id}');
        emit(AuthProfileComplete(user: event.user, profile: event.profile));
      } catch (e) {
        print('AuthBloc: Profile update failed: $e');
        emit(AuthError(e.toString()));
      }
    });
  }
}
