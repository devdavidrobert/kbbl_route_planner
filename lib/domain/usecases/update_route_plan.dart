// lib/domain/usecases/update_route_plan.dart
import '../entities/route_plan.dart';
import '../repositories/route_plan_repository.dart';

class UpdateRoutePlan {
  final RoutePlanRepository repository;

  UpdateRoutePlan(this.repository);

  Future<void> call(RoutePlan routePlan) async {
    await repository.updateRoutePlan(routePlan);
  }
}
