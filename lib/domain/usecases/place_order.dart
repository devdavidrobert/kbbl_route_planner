// lib/domain/usecases/place_order.dart
import '../entities/order.dart';
import '../repositories/order_repository.dart';

// class PlaceOrderUseCase {
//   final OrderRepository repository;

//   PlaceOrderUseCase(this.repository);

//   Future<void> execute(Order order) async {
//     await repository.placeOrder(order);
//   }
// }


class PlaceOrderUseCase {
  final OrderRepository repository;
  PlaceOrderUseCase(this.repository);
  Future<void> call(Order order) => repository.placeOrder(order);
}
