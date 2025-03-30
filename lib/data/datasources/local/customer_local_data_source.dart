// lib/data/datasources/local/customer_local_data_source.dart
import 'package:sqflite/sqflite.dart';
import '../../models/customer_model.dart';
import '../../../core/helpers/database_helper.dart';

class CustomerLocalDataSource {
  final DatabaseHelper dbHelper;

  CustomerLocalDataSource(this.dbHelper);

  Future<List<CustomerModel>> getCustomers(String userId) async {
    final db = await dbHelper.database;
    final customerMaps =
        await db.query('customers', where: 'userId = ?', whereArgs: [userId]);
    final customers = <CustomerModel>[];

    for (var customerMap in customerMaps) {
      final distributorMaps = await db.query(
        'distributors',
        where: 'customerId = ?',
        whereArgs: [customerMap['id']],
      );
      final customer = CustomerModel.fromJson({
        ...customerMap,
        'distributors': distributorMaps,
        'location': {
          'locationName': customerMap['locationName'],
          'coordinates': {
            'latitude': customerMap['latitude'],
            'longitude': customerMap['longitude'],
          },
        },
      });
      customers.add(customer);
    }
    return customers;
  }

  Future<void> addCustomer(CustomerModel customer) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.insert(
          'customers',
          {
            'id': customer.id,
            'name': customer.name,
            'locationName': customer.location.locationName,
            'latitude': customer.location.coordinates.latitude,
            'longitude': customer.location.coordinates.longitude,
            'userId': customer.userId,
            'region': customer.region,
            'territory': customer.territory,
            'createdAt': customer.createdAt.toIso8601String(),
            'updatedAt': customer.updatedAt.toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace);

      for (var distributor in customer.distributors) {
        await txn.insert(
            'distributors',
            {
              'id': distributor.id,
              'customerId': customer.id,
              'name': distributor.name,
              'invoiceName': distributor.invoiceName,
            },
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.update(
        'customers',
        {
          'name': customer.name,
          'locationName': customer.location.locationName,
          'latitude': customer.location.coordinates.latitude,
          'longitude': customer.location.coordinates.longitude,
          'userId': customer.userId,
          'region': customer.region,
          'territory': customer.territory,
          'updatedAt': customer.updatedAt.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [customer.id],
      );

      // Delete existing distributors
      await txn.delete(
        'distributors',
        where: 'customerId = ?',
        whereArgs: [customer.id],
      );

      // Insert updated distributors
      for (var distributor in customer.distributors) {
        await txn.insert(
          'distributors',
          {
            'id': distributor.id,
            'customerId': customer.id,
            'name': distributor.name,
            'invoiceName': distributor.invoiceName,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> deleteCustomer(String customerId) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      // Delete distributors first due to foreign key constraint
      await txn.delete(
        'distributors',
        where: 'customerId = ?',
        whereArgs: [customerId],
      );

      // Delete customer
      await txn.delete(
        'customers',
        where: 'id = ?',
        whereArgs: [customerId],
      );
    });
  }
}
