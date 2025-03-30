// lib/presentation/blocs/route_plan/route_plan_event.dart
import '../../../domain/entities/route_plan.dart';

abstract class RoutePlanEvent {}

class LoadRoutePlans extends RoutePlanEvent {
  final String userId;

  LoadRoutePlans(this.userId);
}

class CreateRoutePlanEvent extends RoutePlanEvent {
  final RoutePlan routePlan;

  CreateRoutePlanEvent(this.routePlan);
}

class UpdateRoutePlanEvent extends RoutePlanEvent {
  final RoutePlan routePlan;

  UpdateRoutePlanEvent(this.routePlan);
}
