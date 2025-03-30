// lib/domain/usecases/fetch_orders_use_case.dart
import '../entities/order.dart';
import '../repositories/order_repository.dart';

// class FetchOrdersUseCase {
//   final OrderRepository repository;

//   FetchOrdersUseCase(this.repository);

//   Future<List<Order>> execute(String userId) async {
//     return await repository.getOrders(userId);
//   }
// }

class FetchOrdersUseCase {
  final OrderRepository repository;
  FetchOrdersUseCase(this.repository);
  Future<List<Order>> call(String userId) => repository.getOrders(userId);
}
