// lib/data/datasources/remote/user_profile_remote_data_source.dart (updated)
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../models/user_profile_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/app_constants.dart';

class UserProfileRemoteDataSource {
  final ApiClient apiClient;

  UserProfileRemoteDataSource(this.apiClient);

  Future<UserProfileModel?> getUserProfile(String email) async {
    try {
      final idToken =
          await firebase_auth.FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken == null) throw Exception('User not authenticated');

      print(
          'Fetching user profile from: ${AppConstants.apiBaseUrl}/user_profiles?email=$email');
      final response = await apiClient
          .get(
            '/user_profiles',
            queryParameters: {'email': email},
            options: Options(
              headers: {'Authorization': 'Bearer $idToken'},
              validateStatus: (status) {
                return status != null && (status == 200 || status == 404);
              },
            ),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timed out'),
          );

      print(
          'Get user profile response: ${response.statusCode} ${response.data}');
      if (response.statusCode == 200) {
        if (response.data == null) return null;
        return UserProfileModel.fromJson(response.data);
      } else if (response.statusCode == 404) {
        return null;
      }
      throw Exception(
          'Failed to fetch user profile: ${response.statusMessage}');
    } catch (e) {
      print('Error fetching user profile: $e');
      rethrow;
    }
  }

  Future<void> createUserProfile(UserProfileModel profile) async {
    try {
      final idToken =
          await firebase_auth.FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken == null) throw Exception('User not authenticated');

      print(
          'Creating user profile at: ${AppConstants.apiBaseUrl}/user_profiles');
      print('Request body: ${profile.toJson()}');
      print('Authorization header: Bearer $idToken');
      final response = await apiClient.post(
        '/user_profiles',
        data: profile.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
          validateStatus: (status) {
            if (status == 404) {
              print('Unexpected 404 response when creating user profile');
            }
            return status != null && (status == 201 || status == 404);
          },
        ),
      );

      print(
          'Create user profile response: ${response.statusCode} ${response.data}');
      if (response.statusCode != 201) {
        throw Exception(
            'Failed to create user profile: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile(UserProfileModel profile) async {
    try {
      final idToken =
          await firebase_auth.FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken == null) throw Exception('User not authenticated');

      print(
          'Updating user profile at: ${AppConstants.apiBaseUrl}/user_profiles/${profile.userId}');
      final response = await apiClient.put(
        // Fixed: Changed post to put
        '/user_profiles/${profile.userId}',
        data: profile.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
          validateStatus: (status) {
            return status != null && (status == 200 || status == 404);
          },
        ),
      );

      print(
          'Update user profile response: ${response.statusCode} ${response.data}');
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update user profile: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }
}
