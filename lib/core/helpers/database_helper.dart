import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logging/logging.dart'; // Use 'logging' since it's in your pubspec.yaml

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  static Database? _database;
  final Logger _logger = Logger('DatabaseHelper'); // Use logging.Logger

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'sales_app.db');
    _logger.info('Initializing database at $path');
    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async => await _createTables(db),
      onUpgrade: (db, oldVersion, newVersion) async => await _upgradeDatabase(db, oldVersion, newVersion),
    );
  }

  Future<void> _createTables(Database db) async {
    _logger.info('Creating tables in the database');
    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        name TEXT,
        locationName TEXT,
        latitude REAL,
        longitude REAL,
        userId TEXT,
        region TEXT,
        territory TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        isSynced INTEGER DEFAULT 1
      )
    ''');
    _logger.info('Customers table created successfully');

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

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    _logger.info('Upgrading database from version $oldVersion to $newVersion');
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
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE customers ADD COLUMN region TEXT;');
      await db.execute('ALTER TABLE customers ADD COLUMN territory TEXT;');
      await db.execute('ALTER TABLE customers ADD COLUMN isSynced INTEGER DEFAULT 1;');
    }
    _logger.info('Database upgraded successfully');
  }

  Future<void> clearAllData() async {
    final db = await database;
    _logger.info('Clearing all data from database');
    await db.transaction((txn) async {
      await txn.delete('customers');
      await txn.delete('distributors');
      await txn.delete('route_plans');
      await txn.delete('orders');
      await txn.delete('stock');
    });
    _logger.info('Database cleared successfully');
  }
}