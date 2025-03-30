// lib/data/datasources/remote/sales_remote_data_source.dart
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:logging/logging.dart';
import '../../../core/network/api_client.dart';
import '../../models/sales_model.dart';
import '../../models/customer_model.dart';
import '../../models/route_plan_model.dart';
import '../../../domain/core/failures.dart';

class SalesRemoteDataSource {
  final ApiClient apiClient;
  final _logger = Logger('SalesRemoteDataSource');

  SalesRemoteDataSource({
    required this.apiClient,
    required firebase_auth.FirebaseAuth auth,
  });


  Future<List<SalesModel>> fetchSalesData(String userId) async {
    try {
      final response = await apiClient.get('/sales?userId=$userId');
      
      if (response['data'] != null) {
        final List<dynamic> data = response['data'];
        return data.map((json) => SalesModel.fromJson(json)).toList();
      }
      
      throw ServerFailure('Failed to fetch sales data');
    } catch (e) {
      _logger.severe('Error fetching sales data: $e');
      throw ServerFailure('Failed to fetch sales data: $e');
    }
  }

  Future<List<CustomerModel>> getCustomersWithSales(String userId) async {
    try {
      final response = await apiClient.get('/customers?userId=$userId');
      
      if (response['data'] != null) {
        final List<dynamic> data = response['data']['customers'] ?? [];
        return data.map((json) => CustomerModel.fromJson(json)).toList();
      }
      
      throw ServerFailure('Failed to fetch customers');
    } catch (e) {
      _logger.severe('Error fetching customers: $e');
      throw ServerFailure('Failed to fetch customers: $e');
    }
  }

  Future<List<RoutePlanModel>> getRoutePlans(String userId) async {
    try {
      final response = await apiClient.get('/sales/route-plans?userId=$userId');
      
      if (response['data'] != null) {
        final List<dynamic> data = response['data'];
        return data.map((json) => RoutePlanModel.fromJson(json)).toList();
      }
      
      throw ServerFailure('Failed to fetch route plans');
    } catch (e) {
      _logger.severe('Error fetching route plans: $e');
      throw ServerFailure('Failed to fetch route plans: $e');
    }
  }

  Future<Map<String, dynamic>> getCustomerPerformance(String customerId, String userId) async {
    try {
      final response = await apiClient.get('/sales/performance?customerId=$customerId&userId=$userId');
      
      if (response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      }
      
      throw ServerFailure('Failed to fetch customer performance');
    } catch (e) {
      _logger.severe('Error fetching customer performance: $e');
      throw ServerFailure('Failed to fetch customer performance: $e');
    }
  }
}
