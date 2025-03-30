import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import '../../models/order_model.dart';
import '../../../core/helpers/database_helper.dart';

class OrderLocalDataSource {
  final DatabaseHelper dbHelper;

  OrderLocalDataSource(this.dbHelper);

  Future<List<OrderModel>> getOrders(String userId) async {
    final db = await dbHelper.database;
    final maps =
        await db.query('orders', where: 'userId = ?', whereArgs: [userId]);
    return maps
        .map((map) => OrderModel.fromJson({
              ...map,
              'skus': jsonDecode(map['skus'] as String),
            }))
        .toList();
  }

  Future<void> placeOrder(OrderModel order) async {
    final db = await dbHelper.database;
    await db.insert(
        'orders',
        {
          'id': order.id,
          'customerId': order.customerId,
          'userId': order.userId,
          'skus': jsonEncode(order.skus),
          'createdAt': order.createdAt.toIso8601String(),
          'updatedAt': order.updatedAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
