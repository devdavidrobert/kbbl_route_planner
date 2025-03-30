// lib/presentation/widgets/route_plan_card.dart
import 'package:flutter/material.dart';
import '../../domain/entities/route_plan.dart';

class RoutePlanCard extends StatelessWidget {
  final RoutePlan routePlan;

  const RoutePlanCard({super.key, required this.routePlan});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              routePlan.route,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Region: ${routePlan.region}'),
            Text('Territory: ${routePlan.territory}'),
            const SizedBox(height: 8),
            const Text('Schedule:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...routePlan.schedule.map((schedule) {
              return Text('Week ${schedule.week}: ${schedule.days.join(', ')}');
            }),
            const SizedBox(height: 8),
            Text('Customers: ${routePlan.customerIds.length} assigned'),
          ],
        ),
      ),
    );
  }
}
