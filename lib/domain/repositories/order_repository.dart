// lib/domain/repositories/order_repository.dart
import '../entities/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders(String userId);
  Future<void> placeOrder(Order order);
}
