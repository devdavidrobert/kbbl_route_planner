// lib/data/repositories/user_profile_repository_impl.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/remote/user_profile_remote_data_source.dart';
import '../models/user_profile_model.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource remoteDataSource;
  final Connectivity connectivity;

  UserProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivity,
  });

  @override
  Future<UserProfile?> getUserProfile(String email) async {
    try {
      print('Checking connectivity for user profile fetch...');
      final connectivityResult = await connectivity.checkConnectivity().timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Connectivity check timed out'),
          );
      if (connectivityResult == ConnectivityResult.none) {
        print('No internet connection, returning null for user profile');
        return null;
      }

      print('Fetching user profile for email: $email');
      final model = await remoteDataSource.getUserProfile(email);
      print('User profile fetched: ${model?.toJson() ?? "null"}');
      return model?.toEntity();
    } catch (e) {
      print('Failed to fetch user profile: $e');
      rethrow;
    }
  }

  @override
  Future<void> createUserProfile(UserProfile profile) async {
    try {
      if (await connectivity.checkConnectivity() == ConnectivityResult.none) {
        throw Exception('No internet connection');
      }
      await remoteDataSource
          .createUserProfile(UserProfileModel.fromEntity(profile));
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      if (await connectivity.checkConnectivity() == ConnectivityResult.none) {
        throw Exception('No internet connection');
      }
      await remoteDataSource
          .updateUserProfile(UserProfileModel.fromEntity(profile));
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }
}
