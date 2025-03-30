// lib/data/repositories/order_repository_impl.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/local/order_local_data_source.dart';
import '../datasources/remote/order_remote_data_source.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderLocalDataSource localDataSource;
  final OrderRemoteDataSource remoteDataSource;
  final Connectivity connectivity;

  OrderRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
  });

  @override
  Future<List<Order>> getOrders(String userId) async {
    if (await connectivity.checkConnectivity() != ConnectivityResult.none) {
      final remoteOrders = await remoteDataSource.getOrders(userId);
      for (var order in remoteOrders) {
        await localDataSource.placeOrder(order);
      }
      return remoteOrders.map((model) => model.toEntity()).toList();
    }
    final localOrders = await localDataSource.getOrders(userId);
    return localOrders.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> placeOrder(Order order) async {
    final model = OrderModel.fromEntity(order);
    if (await connectivity.checkConnectivity() != ConnectivityResult.none) {
      await remoteDataSource.placeOrder(model);
    }
    await localDataSource.placeOrder(model);
  }
}