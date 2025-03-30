// lib/presentation/blocs/route_plan/route_plan_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/create_route_plan.dart';
import '../../../domain/usecases/fetch_routes.dart';
import '../../../domain/usecases/update_route_plan.dart';
import 'route_plan_event.dart';
import 'route_plan_state.dart';

class RoutePlanBloc extends Bloc<RoutePlanEvent, RoutePlanState> {
  final FetchRoutes fetchRoutes;
  final CreateRoutePlan createRoutePlan;
  final UpdateRoutePlan updateRoutePlan;

  RoutePlanBloc({
    required this.fetchRoutes,
    required this.createRoutePlan,
    required this.updateRoutePlan,
  }) : super(RoutePlanInitial()) {
    on<LoadRoutePlans>((event, emit) async {
      emit(RoutePlanLoading());
      try {
        final routePlans = await fetchRoutes(event.userId);
        emit(RoutePlanLoaded(routePlans));
      } catch (e) {
        emit(RoutePlanError(e.toString()));
      }
    });

    on<CreateRoutePlanEvent>((event, emit) async {
      emit(RoutePlanLoading());
      try {
        await createRoutePlan(event.routePlan);
        final routePlans = await fetchRoutes(event.routePlan.userId);
        emit(RoutePlanLoaded(routePlans));
      } catch (e) {
        emit(RoutePlanError(e.toString()));
      }
    });

    on<UpdateRoutePlanEvent>((event, emit) async {
      emit(RoutePlanLoading());
      try {
        await updateRoutePlan(event.routePlan);
        final routePlans = await fetchRoutes(event.routePlan.userId);
        emit(RoutePlanLoaded(routePlans));
      } catch (e) {
        emit(RoutePlanError(e.toString()));
      }
    });
  }
}
