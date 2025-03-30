import 'package:equatable/equatable.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/entities/customer.dart';

abstract class SalesEvent extends Equatable {
  const SalesEvent();
  @override
  List<Object?> get props => [];
}

class FetchOrders extends SalesEvent {
  final String userId;
  const FetchOrders(this.userId);
  @override
  List<Object?> get props => [userId];
}

class PlaceOrderEvent extends SalesEvent {
  final Order order;
  const PlaceOrderEvent(this.order);
  @override
  List<Object?> get props => [order];
}

class EnrollCustomer extends SalesEvent {
  final Customer customer; // Fixed to include customer
  const EnrollCustomer(this.customer);
  @override
  List<Object?> get props => [customer];
}

class FetchSalesData extends SalesEvent {
  final String userId;
  const FetchSalesData(this.userId);
  @override
  List<Object?> get props => [userId];
}