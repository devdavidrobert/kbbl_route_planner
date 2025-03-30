// lib/data/datasources/remote/stock_remote_data_source.dart
import '../../models/stock_model.dart';
import '../../../core/network/api_client.dart';

class StockRemoteDataSource {
  final ApiClient apiClient;

  StockRemoteDataSource(this.apiClient);

  Future<List<StockModel>> getStock(String userId) async {
    final response =
        await apiClient.get('/stock', queryParameters: {'userId': userId});
    if (response.statusCode == 200) {
      return (response.data as List)
          .map((json) => StockModel.fromJson(json))
          .toList();
    }
    throw Exception('Failed to fetch stock');
  }

  Future<void> updateStock(StockModel stock) async {
    final response =
        await apiClient.put('/stock/${stock.id}', data: stock.toJson());
    if (response.statusCode != 200) throw Exception('Failed to update stock');
  }
}
