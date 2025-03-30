// lib/data/datasources/remote/route_plan_remote_data_source.dart
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:logging/logging.dart';
import '../../models/route_plan_model.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/core/failures.dart';

class RoutePlanRemoteDataSource {
  final ApiClient apiClient;
  final _logger = Logger('RoutePlanRemoteDataSource');

  RoutePlanRemoteDataSource({
    required this.apiClient,
    required firebase_auth.FirebaseAuth auth,
  });


  Future<List<RoutePlanModel>> getRoutePlans(String userId) async {
    try {
      final response = await apiClient.get('/route_plans?userId=$userId');
      
      if (response['data'] != null) {
        final List<dynamic> data = response['data']['route_plans'] ?? [];
        return data.map((json) => RoutePlanModel.fromJson(json)).toList();
      }

      throw ServerFailure('Failed to fetch route plans');
    } catch (e) {
      _logger.severe('Error fetching route plans: $e');
      throw ServerFailure('Failed to fetch route plans: $e');
    }
  }

  Future<RoutePlanModel> createRoutePlan(RoutePlanModel routePlan) async {
    try {
      final response = await apiClient.post('/route_plans', routePlan.toJson());
      
      if (response['data'] != null) {
        return RoutePlanModel.fromJson(response['data']);
      }

      throw ServerFailure('Failed to create route plan');
    } catch (e) {
      _logger.severe('Error creating route plan: $e');
      throw ServerFailure('Failed to create route plan: $e');
    }
  }

  Future<RoutePlanModel> updateRoutePlan(RoutePlanModel routePlan) async {
    try {
      final response = await apiClient.put('/route_plans/${routePlan.id}', routePlan.toJson());
      
      if (response['data'] != null) {
        return RoutePlanModel.fromJson(response['data']);
      }

      throw ServerFailure('Failed to update route plan');
    } catch (e) {
      _logger.severe('Error updating route plan: $e');
      throw ServerFailure('Failed to update route plan: $e');
    }
  }

  Future<void> deleteRoutePlan(String routePlanId) async {
    try {
      await apiClient.delete('/route_plans/$routePlanId');
    } catch (e) {
      _logger.severe('Error deleting route plan: $e');
      throw ServerFailure('Failed to delete route plan: $e');
    }
  }
}
