// lib/presentation/pages/route_management_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/route_plan/route_plan_bloc.dart';
import '../blocs/route_plan/route_plan_event.dart';
import '../blocs/route_plan/route_plan_state.dart';
import '../widgets/route_plan_card.dart';
import 'create_route_plan_page.dart';

class RouteManagementPage extends StatelessWidget {
  final String userId;

  const RouteManagementPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Routes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateRoutePlanPage(userId: userId),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<RoutePlanBloc, RoutePlanState>(
        builder: (context, state) {
          if (state is RoutePlanLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RoutePlanLoaded) {
            return ListView.builder(
              itemCount: state.routePlans.length,
              itemBuilder: (context, index) {
                final routePlan = state.routePlans[index];
                return RoutePlanCard(routePlan: routePlan);
              },
            );
          } else if (state is RoutePlanError) {
            return Center(child: Text(state.message));
          }
          return Center(
            child: ElevatedButton(
              onPressed: () {
                context.read<RoutePlanBloc>().add(LoadRoutePlans(userId));
              },
              child: const Text('Load Route Plans'),
            ),
          );
        },
      ),
    );
  }
}
