// lib/data/models/route_plan_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/route_plan.dart';

part 'route_plan_model.g.dart';

@JsonSerializable()
class RoutePlanModel {
  final String id;
  final String userId;
  final String region;
  final String territory;
  final String route;
  final List<ScheduleModel> schedule;
  final List<String> customerIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoutePlanModel({
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

  factory RoutePlanModel.fromJson(Map<String, dynamic> json) =>
      _$RoutePlanModelFromJson(json);
  Map<String, dynamic> toJson() => _$RoutePlanModelToJson(this);

  RoutePlan toEntity() => RoutePlan(
        id: id,
        userId: userId,
        region: region,
        territory: territory,
        route: route,
        schedule: schedule.map((s) => s.toEntity()).toList(),
        customerIds: customerIds,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static RoutePlanModel fromEntity(RoutePlan routePlan) => RoutePlanModel(
        id: routePlan.id,
        userId: routePlan.userId,
        region: routePlan.region,
        territory: routePlan.territory,
        route: routePlan.route,
        schedule:
            routePlan.schedule.map((s) => ScheduleModel.fromEntity(s)).toList(),
        customerIds: routePlan.customerIds,
        createdAt: routePlan.createdAt,
        updatedAt: routePlan.updatedAt,
      );
}

@JsonSerializable()
class ScheduleModel {
  final int week;
  final List<String> days;

  ScheduleModel({
    required this.week,
    required this.days,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleModelFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduleModelToJson(this);

  Schedule toEntity() => Schedule(
        week: week,
        days: days,
      );

  static ScheduleModel fromEntity(Schedule schedule) => ScheduleModel(
        week: schedule.week,
        days: schedule.days,
      );
}
