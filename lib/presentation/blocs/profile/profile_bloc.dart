// lib/presentation/blocs/profile/profile_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/update_profile_use_case.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileBloc(this.updateProfileUseCase) : super(ProfileInitial()) {
    on<UpdateProfileRequested>((event, emit) async {
      emit(ProfileLoading());
      try {
        await updateProfileUseCase.execute(event.profile);
        emit(ProfileUpdated(event.profile));
      } catch (e) {
        emit(ProfileError('Failed to update profile: $e'));
      }
    });
  }
}
