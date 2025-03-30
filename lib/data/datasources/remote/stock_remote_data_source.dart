// lib/data/datasources/remote/stock_remote_data_source.dart
import '../../models/stock_model.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/core/failures.dart';
import 'package:logging/logging.dart';

class StockRemoteDataSource {
  final ApiClient apiClient;
  final _logger = Logger('StockRemoteDataSource');

  StockRemoteDataSource(this.apiClient);

  Future<List<StockModel>> getStock(String userId) async {
    try {
      final response = await apiClient.get('/stock?userId=$userId');
      
      if (response['data'] != null) {
        final List<dynamic> data = response['data'];
        return data.map((json) => StockModel.fromJson(json)).toList();
      }
      
      throw ServerFailure('Failed to fetch stock');
    } catch (e) {
      _logger.severe('Error fetching stock: $e');
      throw ServerFailure('Failed to fetch stock: $e');
    }
  }

  Future<void> updateStock(StockModel stock) async {
    try {
      final response = await apiClient.put('/stock/${stock.id}', stock.toJson());
      
      if (response['error'] != null) {
        throw ServerFailure('Failed to update stock: ${response['error']}');
      }
    } catch (e) {
      _logger.severe('Error updating stock: $e');
      throw ServerFailure('Failed to update stock: $e');
    }
  }
}
