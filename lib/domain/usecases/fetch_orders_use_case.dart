// lib/domain/usecases/fetch_orders_use_case.dart
import '../entities/order.dart';
import '../repositories/sales_repository.dart';

class FetchOrdersUseCase {
  final SalesRepository repository;

  FetchOrdersUseCase(this.repository);

  Future<List<Order>> execute(String userId) async {
    return await repository.fetchOrders(userId);
  }
}
