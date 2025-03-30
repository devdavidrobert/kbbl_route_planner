// lib/data/repositories/route_plan_repository_impl.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/route_plan.dart';
import '../../domain/repositories/route_plan_repository.dart';
import '../datasources/local/route_plan_local_data_source.dart';
import '../datasources/remote/route_plan_remote_data_source.dart';
import '../models/route_plan_model.dart';

class RoutePlanRepositoryImpl implements RoutePlanRepository {
  final RoutePlanLocalDataSource localDataSource;
  final RoutePlanRemoteDataSource remoteDataSource;
  final Connectivity connectivity;

  RoutePlanRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
  });

  @override
  Future<List<RoutePlan>> getRoutePlans(String userId) async {
    if (await connectivity.checkConnectivity() != ConnectivityResult.none) {
      final remoteRoutePlans = await remoteDataSource.getRoutePlans(userId);
      for (var routePlan in remoteRoutePlans) {
        await localDataSource.createRoutePlan(routePlan);
      }
      return remoteRoutePlans.map((model) => model.toEntity()).toList();
    }
    final localRoutePlans = await localDataSource.getRoutePlans(userId);
    return localRoutePlans.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> createRoutePlan(RoutePlan routePlan) async {
    final model = RoutePlanModel.fromEntity(routePlan);
    if (await connectivity.checkConnectivity() != ConnectivityResult.none) {
      await remoteDataSource.createRoutePlan(model);
    }
    await localDataSource.createRoutePlan(model);
  }

  @override
  Future<void> updateRoutePlan(RoutePlan routePlan) async {
    final model = RoutePlanModel.fromEntity(routePlan);
    if (await connectivity.checkConnectivity() != ConnectivityResult.none) {
      await remoteDataSource.updateRoutePlan(model);
    }
    await localDataSource.updateRoutePlan(model);
  }
}
