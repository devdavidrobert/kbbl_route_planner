// lib/domain/repositories/route_plan_repository.dart
import '../entities/route_plan.dart';

abstract class RoutePlanRepository {
  Future<List<RoutePlan>> getRoutePlans(String userId);
  Future<void> createRoutePlan(RoutePlan routePlan);
  Future<void> updateRoutePlan(RoutePlan routePlan);
}
