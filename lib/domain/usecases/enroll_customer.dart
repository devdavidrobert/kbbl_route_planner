// lib/domain/usecases/enroll_customer.dart
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

// class EnrollCustomerUseCase {
//   final CustomerRepository repository;

//   EnrollCustomerUseCase(this.repository);

//   Future<void> execute(Customer customer) async {
//     await repository.addCustomer(customer);
//   }
// }

class EnrollCustomerUseCase {
  final CustomerRepository repository;
  EnrollCustomerUseCase(this.repository);
  Future<void> call(Customer customer) => repository.addCustomer(customer);
}
