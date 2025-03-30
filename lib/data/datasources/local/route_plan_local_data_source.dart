// lib/data/datasources/local/route_plan_local_data_source.dart
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../models/route_plan_model.dart';
import '../../../core/helpers/database_helper.dart';

class RoutePlanLocalDataSource {
  final DatabaseHelper dbHelper;

  RoutePlanLocalDataSource(this.dbHelper);

  Future<List<RoutePlanModel>> getRoutePlans(String userId) async {
    final db = await dbHelper.database;
    final maps =
        await db.query('route_plans', where: 'userId = ?', whereArgs: [userId]);
    return maps
        .map((map) => RoutePlanModel.fromJson({
              ...map,
              'schedule': jsonDecode(map['schedule'] as String),
              'customerIds': jsonDecode(map['customerIds'] as String),
            }))
        .toList();
  }

  Future<void> createRoutePlan(RoutePlanModel routePlan) async {
    final db = await dbHelper.database;
    await db.insert(
        'route_plans',
        {
          'id': routePlan.id,
          'userId': routePlan.userId,
          'region': routePlan.region,
          'territory': routePlan.territory,
          'route': routePlan.route,
          'schedule':
              jsonEncode(routePlan.schedule.map((s) => s.toJson()).toList()),
          'customerIds': jsonEncode(routePlan.customerIds),
          'createdAt': routePlan.createdAt.toIso8601String(),
          'updatedAt': routePlan.updatedAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateRoutePlan(RoutePlanModel routePlan) async {
    final db = await dbHelper.database;
    await db.update(
      'route_plans',
      {
        'id': routePlan.id,
        'userId': routePlan.userId,
        'region': routePlan.region,
        'territory': routePlan.territory,
        'route': routePlan.route,
        'schedule':
            jsonEncode(routePlan.schedule.map((s) => s.toJson()).toList()),
        'customerIds': jsonEncode(routePlan.customerIds),
        'createdAt': routePlan.createdAt.toIso8601String(),
        'updatedAt': routePlan.updatedAt.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [routePlan.id],
    );
  }
}
