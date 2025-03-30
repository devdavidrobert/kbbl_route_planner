// lib/data/datasources/local/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'sales_app.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS distributors');
          await db.execute('''
            CREATE TABLE distributors (
              id TEXT PRIMARY KEY,
              customerId TEXT,
              name TEXT,
              invoiceName TEXT,
              FOREIGN KEY (customerId) REFERENCES customers(id)
            )
          ''');
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        name TEXT,
        locationName TEXT,
        latitude REAL,
        longitude REAL,
        userId TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE distributors (
        id TEXT PRIMARY KEY,
        customerId TEXT,
        name TEXT,
        invoiceName TEXT,
        FOREIGN KEY (customerId) REFERENCES customers(id)
      )
    ''');
    
    await db.execute('''
      CREATE TABLE route_plans (
        id TEXT PRIMARY KEY,
        userId TEXT,
        region TEXT,
        territory TEXT,
        route TEXT,
        schedule TEXT,
        customerIds TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        customerId TEXT,
        userId TEXT,
        skus TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE stock (
        id TEXT PRIMARY KEY,
        customerId TEXT,
        userId TEXT,
        status TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('customers');
      await txn.delete('distributors');
      await txn.delete('route_plans');
      await txn.delete('orders');
      await txn.delete('stock');
    });
  }
}
