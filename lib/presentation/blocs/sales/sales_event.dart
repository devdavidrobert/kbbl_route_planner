// lib/presentation/blocs/sales/sales_event.dart
import '../../../domain/entities/customer.dart';
import '../../../domain/entities/distributor.dart';
import '../../../domain/entities/location.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/entities/stock.dart';

abstract class SalesEvent {}

class LoadSalesData extends SalesEvent {
  final String userId;

  LoadSalesData(this.userId);
}

class AddCustomerEvent extends SalesEvent {
  final Customer customer;

  AddCustomerEvent(this.customer);
}

class PlaceOrderEvent extends SalesEvent {
  final Order order;

  PlaceOrderEvent(this.order);
}

class TrackStockEvent extends SalesEvent {
  final Stock stock;

  TrackStockEvent(this.stock);
}

class GetCustomerPerformanceEvent extends SalesEvent {
  final String customerId;
  final String userId;

  GetCustomerPerformanceEvent(this.customerId, this.userId);
}

class FetchOrders extends SalesEvent {
  final String userId;

  FetchOrders(this.userId);
}

class PlaceOrder extends SalesEvent {
  final String userId;
  final String customerId;
  final Map<String, Map<String, int>> skus;

  PlaceOrder({
    required this.userId,
    required this.customerId,
    required this.skus,
  });
}

class EnrollCustomer extends SalesEvent {
  final String customerId;
  final String customerName;
  final String userId;
  final List<Distributor> distributors;
  final String invoiceName;
  final Location location;

  EnrollCustomer({
    required this.customerId,
    required this.customerName,
    required this.userId,
    required this.distributors,
    required this.invoiceName,
    required this.location,
  });
}
