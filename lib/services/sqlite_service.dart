import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter/foundation.dart';

import '../models/appointment/appointment.dart';

class SQLiteService {
  static final SQLiteService instance = SQLiteService._init();

  static Database? _database;

  SQLiteService._init();

  Future<Database> get database async{
    if (_database != null){
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async{
    String path;

    if (kIsWeb) {
      path = 'solar_booking.db';
    } else {
      final databasePath = await getDatabasesPath();
      path = join(databasePath, 'solar_booking.db');
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE appointments(
      id TEXT PRIMARY KEY,
        company_id TEXT NOT NULL,
        company_name TEXT NOT NULL,
        service_type TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        address TEXT NOT NULL,
        notes TEXT,
        status TEXT NOT NULL,
        image_path TEXT,
        latitude REAL,
        longitude REAL,
        created_at TEXT
        )
      ''');
  }

  Future<void> insert(Appointment appointment) async{
    final db = await instance.database;

    await db.insert(
        'appointments',
        appointment.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(Appointment appointment) async{
    final db = await instance.database;

    await db.update(
        'appointments',
        appointment.toJson(),
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
  }

  Future<void> delete(String id) async{
    final db = await instance.database;

    await db.delete(
        'appointments',
        where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Appointment>> getAll() async{
      final db = await instance.database;

      final result = await db.query(
        'appointments',
        orderBy: 'created_at DESC',
      );

      return result.map((json) => Appointment.fromJson(json)).toList();
  }

  Future<Appointment?> getById(String id) async {
    final db = await instance.database;

    final result = await db.query(
        'appointments',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty){
      return null;
    }

    return Appointment.fromJson(result.first);
  }

  Future<void> close() async{
    final db = await instance.database;

    await db.close();
  }
}