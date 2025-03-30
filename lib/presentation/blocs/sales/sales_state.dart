import 'package:equatable/equatable.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/entities/customer.dart';

abstract class SalesState extends Equatable {
  const SalesState();
  @override
  List<Object?> get props => [];
}

class SalesInitial extends SalesState {}

class SalesLoading extends SalesState {}

class OrdersLoaded extends SalesState {
  final List<Order> orders;
  const OrdersLoaded(this.orders);
  @override
  List<Object?> get props => [orders];
}

class CustomersLoaded extends SalesState {
  final List<Customer> customers;
  const CustomersLoaded(this.customers);
  @override
  List<Object?> get props => [customers];
}

class OrderPlaced extends SalesState {
  final String orderId;
  const OrderPlaced(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

class CustomerEnrolled extends SalesState {
  final String customerId;
  const CustomerEnrolled(this.customerId);
  @override
  List<Object?> get props => [customerId];
}

class SalesError extends SalesState {
  final String message;
  const SalesError(this.message);
  @override
  List<Object?> get props => [message];
}