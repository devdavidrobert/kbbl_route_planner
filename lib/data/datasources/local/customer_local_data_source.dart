// lib/data/datasources/local/customer_local_data_source.dart
import 'package:sqflite/sqflite.dart';
import '../../models/customer_model.dart';
import 'database_helper.dart';

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
            'invoiceName': customer.invoiceName,
            'locationName': customer.location.locationName,
            'latitude': customer.location.coordinates.latitude,
            'longitude': customer.location.coordinates.longitude,
            'userId': customer.userId,
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
              'contactInfo': distributor.contactInfo,
            },
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }
}
