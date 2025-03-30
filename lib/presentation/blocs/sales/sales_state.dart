// lib/presentation/blocs/sales/sales_state.dart
import '../../../domain/entities/customer.dart';
import '../../../domain/entities/route_plan.dart';
import '../../../domain/entities/order.dart';

abstract class SalesState {}

class SalesInitial extends SalesState {}

class SalesLoading extends SalesState {}

class SalesDataLoaded extends SalesState {
  final List<Customer> customers;
  final List<RoutePlan> routePlans;
  final Map<String, dynamic>? performance;

  SalesDataLoaded({
    required this.customers,
    required this.routePlans,
    this.performance,
  });
}

class SalesError extends SalesState {
  final String message;

  SalesError({required this.message});
}

class OrdersLoaded extends SalesState {
  final List<Order> orders;

  OrdersLoaded({required this.orders});
}

class OrderPlaced extends SalesState {
  final String orderId;

  OrderPlaced({required this.orderId});
}

class CustomerEnrolled extends SalesState {
  final String customerId;

  CustomerEnrolled({required this.customerId});
}
