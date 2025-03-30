// lib/presentation/blocs/route_plan/route_plan_state.dart
import '../../../domain/entities/route_plan.dart';

abstract class RoutePlanState {}

class RoutePlanInitial extends RoutePlanState {}

class RoutePlanLoading extends RoutePlanState {}

class RoutePlanLoaded extends RoutePlanState {
  final List<RoutePlan> routePlans;

  RoutePlanLoaded(this.routePlans);
}

class RoutePlanError extends RoutePlanState {
  final String message;

  RoutePlanError(this.message);
}
