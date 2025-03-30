// lib/domain/repositories/stock_repository.dart
import '../entities/stock.dart';

abstract class StockRepository {
  Future<List<Stock>> getStock(String userId);
  Future<void> updateStock(Stock stock);
}
