// lib/data/datasources/remote/route_plan_remote_data_source.dart
import '../../models/route_plan_model.dart';
import '../../../core/network/api_client.dart';

class RoutePlanRemoteDataSource {
  final ApiClient apiClient;

  RoutePlanRemoteDataSource(this.apiClient);

  Future<List<RoutePlanModel>> getRoutePlans(String userId) async {
    final response = await apiClient
        .get('/route_plans', queryParameters: {'userId': userId});
    if (response.statusCode == 200) {
      return (response.data as List)
          .map((json) => RoutePlanModel.fromJson(json))
          .toList();
    }
    throw Exception('Failed to fetch route plans');
  }

  Future<void> createRoutePlan(RoutePlanModel routePlan) async {
    final response =
        await apiClient.post('/route_plans', data: routePlan.toJson());
    if (response.statusCode != 201) {
      throw Exception('Failed to create route plan');
    }
  }

  Future<void> updateRoutePlan(RoutePlanModel routePlan) async {
    final response = await apiClient.put('/route_plans/${routePlan.id}',
        data: routePlan.toJson());
    if (response.statusCode != 200) {
      throw Exception('Failed to update route plan');
    }
  }
}
