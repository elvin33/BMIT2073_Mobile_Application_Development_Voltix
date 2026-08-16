import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as mobile;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../models/usage/report_model.dart';
import '../../models/usage/usage_model.dart';
import '../../models/usage/user_profile_model.dart';


class DatabaseService {
  factory DatabaseService() => _instance;

  DatabaseService._internal()
      : _factoryOverride = null,
        _pathOverride = null;

  DatabaseService.forTesting({
    required DatabaseFactory databaseFactory,
    required String databasePath,
  })  : _factoryOverride = databaseFactory,
        _pathOverride = databasePath;

  static final DatabaseService _instance = DatabaseService._internal();
  static const databaseVersion = 5;

  final DatabaseFactory? _factoryOverride;
  final String? _pathOverride;
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final factory = _factoryOverride ?? _platformFactory();
    final databasePath = _pathOverride ??
        join(await factory.getDatabasesPath(), 'energy_usage.db');
    return factory.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: databaseVersion,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
      ),
    );
  }

  DatabaseFactory _platformFactory() {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      return databaseFactoryFfi;
    }
    return mobile.databaseFactorySqflitePlugin;
  }

  Future<String> getStorageDirectory() async {
    final factory = _factoryOverride ?? _platformFactory();
    return factory.getDatabasesPath();
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usage(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        kwh REAL NOT NULL,
        state TEXT NOT NULL,
        percentage REAL NOT NULL,
        isAbove INTEGER NOT NULL,
        level INTEGER NOT NULL,
        dateCreated TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE reports(
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        state TEXT NOT NULL,
        contact TEXT,
        photoPath TEXT,
        dateSubmitted TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE user_profile(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        address TEXT NOT NULL,
        sector TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE reports(
          id TEXT PRIMARY KEY,
          category TEXT,
          description TEXT,
          state TEXT,
          photoPath TEXT,
          dateSubmitted TEXT
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE user_profile(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          email TEXT,
          address TEXT,
          sector TEXT
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute(
        "ALTER TABLE usage ADD COLUMN state TEXT NOT NULL DEFAULT 'Unknown'",
      );
      await db.execute(
        'ALTER TABLE usage ADD COLUMN percentage REAL NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE usage ADD COLUMN isAbove INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE reports ADD COLUMN contact TEXT');
    }
  }

  Future<int> insertUsage(UserUsage usage) async {
    final db = await database;
    return db.insert('usage', usage.toMap());
  }

  Future<int> insertReport(EnergyReport report) async {
    final db = await database;
    return db.insert('reports', report.toMap());
  }

  Future<List<UserUsage>> getAllUsage() async {
    final db = await database;
    final maps = await db.query('usage', orderBy: 'dateCreated DESC');
    return maps.map(UserUsage.fromMap).toList();
  }

  Future<List<EnergyReport>> getAllReports() async {
    final db = await database;
    final maps = await db.query('reports', orderBy: 'dateSubmitted DESC');
    return maps.map(EnergyReport.fromMap).toList();
  }

  Future<UserProfile> getUserProfile() async {
    final db = await database;
    final maps = await db.query(
      'user_profile',
      where: 'id = ?',
      whereArgs: const [1],
      limit: 1,
    );
    return maps.isEmpty ? UserProfile.empty : UserProfile.fromMap(maps.first);
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final db = await database;
    await db.insert(
      'user_profile',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
