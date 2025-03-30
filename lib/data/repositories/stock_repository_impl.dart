// lib/data/repositories/stock_repository_impl.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/stock.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/local/stock_local_data_source.dart';
import '../datasources/remote/stock_remote_data_source.dart';
import '../models/stock_model.dart';

class StockRepositoryImpl implements StockRepository {
  final StockLocalDataSource localDataSource;
  final StockRemoteDataSource remoteDataSource;
  final Connectivity connectivity;

  StockRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
  });

  @override
  Future<List<Stock>> getStock(String userId) async {
    if (await connectivity.checkConnectivity() != ConnectivityResult.none) {
      final remoteStock = await remoteDataSource.getStock(userId);
      for (var stock in remoteStock) {
        await localDataSource.updateStock(stock);
      }
      return remoteStock.map((model) => model.toEntity()).toList();
    }
    final localStock = await localDataSource.getStock(userId);
    return localStock.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> updateStock(Stock stock) async {
    final model = StockModel.fromEntity(stock);
    if (await connectivity.checkConnectivity() != ConnectivityResult.none) {
      await remoteDataSource.updateStock(model);
    }
    await localDataSource.updateStock(model);
  }
}