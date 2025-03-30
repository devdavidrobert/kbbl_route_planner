// lib/domain/usecases/fetch_routes.dart
import '../entities/route_plan.dart';
import '../repositories/route_plan_repository.dart';

class FetchRoutes {
  final RoutePlanRepository repository;

  FetchRoutes(this.repository);

  Future<List<RoutePlan>> call(String userId) async {
    return await repository.getRoutePlans(userId);
  }
}
