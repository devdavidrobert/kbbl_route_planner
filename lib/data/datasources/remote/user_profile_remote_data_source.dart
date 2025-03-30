// lib/data/datasources/remote/user_profile_remote_data_source.dart (updated)
import 'package:logging/logging.dart';
import '../../models/user_profile_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/error/exceptions.dart';

class UserProfileRemoteDataSource {
  final ApiClient apiClient;
  final _logger = Logger('UserProfileRemoteDataSource');

  UserProfileRemoteDataSource(this.apiClient);


  Future<UserProfileModel?> getUserProfile(String email) async {
    try {
      _logger.info('Fetching user profile for email: $email');
      
      final response = await apiClient.get('/users/profile?email=$email');
      
      _logger.info('Response received: $response');

      if (response['status'] == 404) {
        _logger.info('User profile not found');
        return null;
      }

      if (response['status'] != 200) {
        _logger.warning('Failed to fetch profile. Status: ${response['status']}');
        throw ServerException('Failed to fetch user profile');
      }

      final data = response['data'];
      if (data == null) {
        _logger.warning('Response data is null');
        return null;
      }

      _logger.info('Successfully fetched user profile');
      return UserProfileModel.fromJson(data);
    } catch (e) {
      _logger.severe('Error fetching user profile: $e');
      rethrow;
    }
  }

  Future<void> createUserProfile(UserProfileModel profile) async {
    try {
      _logger.info('Creating user profile for email: ${profile.email}');
      
      final now = DateTime.now().toUtc();
      
      // Prepare the data according to the MongoDB schema
      final data = {
        'userId': profile.userId,
        'email': profile.email,
        'name': profile.name,
        'region': profile.region,
        'territory': profile.territory,
        'branch': profile.branch,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };
      
      _logger.fine('Sending profile data: $data');
      
      final response = await apiClient.post('/users/profile', data);
      
      _logger.info('Response received: $response');

      if (response['status'] != 201) {
        _logger.warning('Failed to create profile. Status: ${response['status']}');
        throw ServerException('Failed to create user profile');
      }

      _logger.info('Successfully created user profile');
    } catch (e) {
      _logger.severe('Error creating user profile: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile(UserProfileModel profile) async {
    try {
      _logger.info('Updating user profile for email: ${profile.email}');
      
      final now = DateTime.now().toUtc();
      
      // Prepare the data according to the MongoDB schema
      final data = {
        'userId': profile.userId,
        'email': profile.email,
        'name': profile.name,
        'region': profile.region,
        'territory': profile.territory,
        'branch': profile.branch,
        'updatedAt': now.toIso8601String(),
      };
      
      _logger.fine('Sending profile data: $data');
      
      final response = await apiClient.put('/users/profile/${profile.userId}', data);
      
      _logger.info('Response received: $response');

      if (response['status'] != 200) {
        _logger.warning('Failed to update profile. Status: ${response['status']}');
        throw ServerException('Failed to update user profile');
      }

      _logger.info('Successfully updated user profile');
    } catch (e) {
      _logger.severe('Error updating user profile: $e');
      rethrow;
    }
  }
}
