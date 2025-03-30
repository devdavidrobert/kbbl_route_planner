// lib/domain/usecases/fetch_sales_data_use_case.dart
import '../entities/sales.dart';
import '../entities/customer.dart';
import '../entities/route_plan.dart';
import '../repositories/sales_repository.dart';

// class FetchSalesDataUseCase {
//   final SalesRepository repository;

//   FetchSalesDataUseCase(this.repository);

//   Future<List<Sales>> execute(String userId) async {
//     return await repository.fetchSalesData(userId);
//   }

//   Future<List<Customer>> getCustomersWithSales(String userId) async {
//     return await repository.getCustomersWithSales(userId);
//   }

//   Future<List<RoutePlan>> getRoutePlans(String userId) async {
//     return await repository.getRoutePlans(userId);
//   }

//   Future<Map<String, dynamic>> getCustomerPerformance(String customerId, String userId) async {
//     return await repository.getCustomerPerformance(customerId, userId);
//   }
// }


class FetchSalesDataUseCase {
  final SalesRepository repository; // Adjust repository type
  FetchSalesDataUseCase(this.repository);
  Future<void> call(String userId) => repository.fetchSalesData(userId); // Adjust return type if needed
}