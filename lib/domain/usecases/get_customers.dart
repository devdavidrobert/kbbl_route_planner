// lib/domain/usecases/get_customers.dart
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class GetCustomers {
  final CustomerRepository repository;

  GetCustomers(this.repository);

  Future<List<Customer>> call(String userId) async {
    return await repository.getCustomers(userId);
  }
}
