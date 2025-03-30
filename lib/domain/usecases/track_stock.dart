// lib/domain/usecases/track_stock.dart
import '../entities/stock.dart';
import '../repositories/stock_repository.dart';

class TrackStock {
  final StockRepository repository;

  TrackStock(this.repository);

  Future<void> call(Stock stock) async {
    await repository.updateStock(stock);
  }
}
