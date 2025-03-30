// lib/domain/usecases/create_route_plan.dart
import '../entities/route_plan.dart';
import '../repositories/route_plan_repository.dart';

class CreateRoutePlan {
  final RoutePlanRepository repository;

  CreateRoutePlan(this.repository);

  Future<void> call(RoutePlan routePlan) async {
    await repository.createRoutePlan(routePlan);
  }
}
