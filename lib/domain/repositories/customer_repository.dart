// lib/domain/repositories/customer_repository.dart
import '../entities/customer.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getCustomers(String userId);
  Future<void> addCustomer(Customer customer);
  Future<void> updateCustomer(Customer customer);
  Future<void> deleteCustomer(String customerId);
}
