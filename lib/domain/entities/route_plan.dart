// lib/domain/entities/route_plan.dart
class RoutePlan {
  final String id;
  final String userId;
  final String region;
  final String territory;
  final String route;
  final List<Schedule> schedule;
  final List<String> customerIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoutePlan({
    required this.id,
    required this.userId,
    required this.region,
    required this.territory,
    required this.route,
    required this.schedule,
    required this.customerIds,
    required this.createdAt,
    required this.updatedAt,
  });
}

class Schedule {
  final int week;
  final List<String> days;

  Schedule({
    required this.week,
    required this.days,
  });
}
