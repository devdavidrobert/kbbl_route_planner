// lib/domain/repositories/sales_repository.dart
import '../entities/order.dart';
import '../entities/distributor.dart';
import '../entities/location.dart';

abstract class SalesRepository {
  Future<List<Order>> fetchOrders(String userId);
  Future<String> placeOrder({
    required String userId,
    required String customerId,
    required Map<String, Map<String, int>> skus,
  });
  Future<String> enrollCustomer({
    required String customerId,
    required String customerName,
    required String userId,
    required List<Distributor> distributors,
    required String invoiceName,
    required Location location,
  });
  Future<void> updateCustomer({
    required String customerId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
  });
  Future<void> deleteCustomer(String customerId);
  Future<void> trackStock(String stockId, int quantity);
  Future<Map<String, dynamic>> getCustomerPerformance(
      String customerId, String userId);
}
