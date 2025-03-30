// lib/domain/usecases/fetch_sales_data_use_case.dart
import '../entities/sales.dart';
import '../repositories/sales_repository.dart';

class FetchSalesDataUseCase {
  final SalesRepository repository;

  FetchSalesDataUseCase(this.repository);

  Future<List<Sales>> execute(String userId) async {
    return await repository.fetchSalesData(userId);
  }
}
