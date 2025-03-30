// lib/data/datasources/local/stock_local_data_source.dart
import 'package:sqflite/sqflite.dart';
import '../../models/stock_model.dart';
import 'database_helper.dart';

class StockLocalDataSource {
  final DatabaseHelper dbHelper;

  StockLocalDataSource(this.dbHelper);

  Future<List<StockModel>> getStock(String userId) async {
    final db = await dbHelper.database;
    final maps =
        await db.query('stock', where: 'userId = ?', whereArgs: [userId]);
    return maps.map((map) => StockModel.fromJson(map)).toList();
  }

  Future<void> updateStock(StockModel stock) async {
    final db = await dbHelper.database;
    await db.insert(
        'stock',
        {
          'id': stock.id,
          'customerId': stock.customerId,
          'userId': stock.userId,
          'status': stock.status,
          'createdAt': stock.createdAt.toIso8601String(),
          'updatedAt': stock.updatedAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
