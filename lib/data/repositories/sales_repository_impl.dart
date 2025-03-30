// lib/data/repositories/sales_repository_impl.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/sales.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/route_plan.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/remote/sales_remote_data_source.dart';

class SalesRepositoryImpl implements SalesRepository {
  final SalesRemoteDataSource remoteDataSource;
  final Connectivity connectivity; // Added connectivity parameter

  SalesRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivity, // Added connectivity initialization
  });

  @override
  Future<List<Sales>> fetchSalesData(String userId) async {
    try {
      final salesModels = await remoteDataSource.fetchSalesData(userId);
      return salesModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getCustomerPerformance(
      String customerId, String userId) async {
    try {
      return await remoteDataSource.getCustomerPerformance(customerId, userId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Customer>> getCustomersWithSales(String userId) async {
    try {
      final customerModels =
          await remoteDataSource.getCustomersWithSales(userId);
      return customerModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<RoutePlan>> getRoutePlans(String userId) async {
    try {
      final routePlanModels = await remoteDataSource.getRoutePlans(userId);
      return routePlanModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }
}
