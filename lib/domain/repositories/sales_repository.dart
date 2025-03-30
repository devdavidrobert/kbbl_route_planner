// lib/domain/repositories/sales_repository.dart
import '../entities/sales.dart';
import '../entities/customer.dart';
import '../entities/route_plan.dart';

abstract class SalesRepository {
  Future<List<Sales>> fetchSalesData(String userId);
  Future<Map<String, dynamic>> getCustomerPerformance(String customerId, String userId);
  Future<List<Customer>> getCustomersWithSales(String userId);
  Future<List<RoutePlan>> getRoutePlans(String userId);
}
