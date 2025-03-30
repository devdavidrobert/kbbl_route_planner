// lib/data/repositories/sales_repository_impl.dart
import 'package:dio/dio.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/distributor.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/remote/sales_remote_data_source.dart';
import '../models/order_model.dart';
import '../models/customer_model.dart';

class SalesRepositoryImpl implements SalesRepository {
  final SalesRemoteDataSource remoteDataSource;

  SalesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Order>> fetchOrders(String userId) async {
    try {
      final orderModels = await remoteDataSource.fetchOrders(userId);
      return orderModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> placeOrder({
    required String userId,
    required String customerId,
    required Map<String, Map<String, int>> skus,
  }) async {
    try {
      final orderId = 'ORDER${DateTime.now().millisecondsSinceEpoch}';
      final orderModel = OrderModel(
        id: orderId,
        customerId: customerId,
        userId: userId,
        skus: skus,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await remoteDataSource.placeOrder(orderModel);
      return orderId;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> enrollCustomer({
    required String customerId,
    required String customerName,
    required String userId,
    required List<Distributor> distributors,
    required String invoiceName,
    required Location location,
  }) async {
    try {
      final customerModel = CustomerModel(
        id: customerId,
        name: customerName,
        userId: userId,
        distributors: distributors,
        invoiceName: invoiceName,
        location: location,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await remoteDataSource.enrollCustomer(customerModel);
      return customerId;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateCustomer({
    required String customerId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
  }) async {
    try {
      await remoteDataSource.updateCustomer(
        customerId: customerId,
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteCustomer(String customerId) async {
    try {
      await remoteDataSource.deleteCustomer(customerId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> trackStock(String stockId, int quantity) async {
    try {
      await remoteDataSource.trackStock(stockId, quantity);
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
}
