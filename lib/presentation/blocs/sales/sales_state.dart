// lib/presentation/blocs/sales/sales_state.dart
import '../../../domain/entities/customer.dart';
import '../../../domain/entities/route_plan.dart';
import '../../../domain/entities/order.dart';

abstract class SalesState {
  const SalesState();
}

class SalesInitial extends SalesState {
  const SalesInitial();
}

class SalesLoading extends SalesState {
  const SalesLoading();
}

class SalesDataLoaded extends SalesState {
  final List<Customer> customers;
  final List<RoutePlan> routePlans;
  final Map<String, dynamic>? performance;

  const SalesDataLoaded({
    required this.customers,
    required this.routePlans,
    this.performance,
  });
}

class SalesError extends SalesState {
  final String message;

  const SalesError({required this.message});
}

class OrdersLoaded extends SalesState {
  final List<Order> orders;

  const OrdersLoaded({required this.orders});
}

class OrderPlaced extends SalesState {
  final String orderId;

  const OrderPlaced({required this.orderId});
}

class CustomerEnrolled extends SalesState {
  final String customerId;

  const CustomerEnrolled({required this.customerId});
}
