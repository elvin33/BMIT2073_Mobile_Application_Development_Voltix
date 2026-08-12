import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ReportDatabaseHelper {
  static final ReportDatabaseHelper instance = ReportDatabaseHelper._init();

  static Database? _database;

  ReportDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('voltix.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(
      Database db,
      int version,
      ) async {
    await db.execute('''
      CREATE TABLE reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        location TEXT NOT NULL,
        urgency TEXT NOT NULL,
        nameEmail TEXT,
        fileName TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertReport(
      Map<String, dynamic> report,
      ) async {
    final db = await instance.database;

    return await db.insert(
      'reports',
      report,
    );
  }

  Future<List<Map<String, dynamic>>> getReports() async {
    final db = await instance.database;

    return await db.query(
      'reports',
      orderBy: 'id DESC',
    );
  }

  Future<int> deleteReport(int id) async {
    final db = await instance.database;

    return await db.delete(
      'reports',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}