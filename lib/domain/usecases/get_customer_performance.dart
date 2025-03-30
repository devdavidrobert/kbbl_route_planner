// lib/domain/usecases/get_customer_performance.dart
import '../repositories/customer_repository.dart';
import '../repositories/order_repository.dart';

class GetCustomerPerformance {
  final CustomerRepository customerRepository;
  final OrderRepository orderRepository;

  GetCustomerPerformance(this.customerRepository, this.orderRepository);

  Future<Map<String, dynamic>> call(String customerId, String userId) async {
    final customers = await customerRepository.getCustomers(userId);
    final customer = customers.firstWhere((c) => c.id == customerId);
    final orders = await orderRepository.getOrders(userId);
    final customerOrders =
        orders.where((o) => o.customerId == customerId).toList();

    double totalVolume = 0.0;
    for (var order in customerOrders) {
      for (var product in order.skus.values) {
        totalVolume += product.values.fold(0, (sum, qty) => sum + qty);
      }
    }

    return {
      'customer': customer,
      'totalOrders': customerOrders.length,
      'totalVolume': totalVolume,
    };
  }
}
