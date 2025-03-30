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
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE customers (
            id TEXT PRIMARY KEY,
            name TEXT,
            invoiceName TEXT,
            locationName TEXT,
            latitude REAL,
            longitude REAL,
            userId TEXT,
            createdAt TEXT,
            updatedAt TEXT
            -- Distributors stored in a separate table
          )
        ''');
        db.execute('''
          CREATE TABLE distributors (
            id TEXT PRIMARY KEY,
            customerId TEXT,
            name TEXT,
            contactInfo TEXT,
            FOREIGN KEY (customerId) REFERENCES customers(id)
          )
        ''');
        db.execute('''
          CREATE TABLE route_plans (
            id TEXT PRIMARY KEY,
            userId TEXT,
            region TEXT,
            territory TEXT,
            route TEXT,
            schedule TEXT, -- Store as JSON string
            customerIds TEXT, -- Store as JSON string
            createdAt TEXT,
            updatedAt TEXT
          )
        ''');
        db.execute('''
          CREATE TABLE orders (
            id TEXT PRIMARY KEY,
            customerId TEXT,
            userId TEXT,
            skus TEXT, -- Store as JSON string
            createdAt TEXT,
            updatedAt TEXT
          )
        ''');
        db.execute('''
          CREATE TABLE stock (
            id TEXT PRIMARY KEY,
            customerId TEXT,
            userId TEXT,
            status TEXT,
            createdAt TEXT,
            updatedAt TEXT
          )
        ''');
      },
    );
  }
}
