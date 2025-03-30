// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoutePlanModel _$RoutePlanModelFromJson(Map<String, dynamic> json) =>
    RoutePlanModel(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      region: json['region'] as String,
      territory: json['territory'] as String,
      route: json['route'] as String,
      schedule: RoutePlanModel._scheduleFromJson(json['schedule'] as List),
      customerIds: (json['customerIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$RoutePlanModelToJson(RoutePlanModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'userId': instance.userId,
      'region': instance.region,
      'territory': instance.territory,
      'route': instance.route,
      'schedule': RoutePlanModel._scheduleToJson(instance.schedule),
      'customerIds': instance.customerIds,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

ScheduleModel _$ScheduleModelFromJson(Map<String, dynamic> json) =>
    ScheduleModel(
      week: (json['week'] as num).toInt(),
      days: (json['days'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ScheduleModelToJson(ScheduleModel instance) =>
    <String, dynamic>{
      'week': instance.week,
      'days': instance.days,
    };
