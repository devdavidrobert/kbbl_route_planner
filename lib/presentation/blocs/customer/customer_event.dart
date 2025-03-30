// lib/presentation/blocs/customer/customer_event.dart
import '../../../domain/entities/customer.dart';

abstract class CustomerEvent {}

class AddCustomer extends CustomerEvent {
  final Customer customer;

  AddCustomer(this.customer);
}
