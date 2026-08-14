import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ReportDatabaseHelper {
  static final ReportDatabaseHelper instance =
  ReportDatabaseHelper._init();

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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(
      Database db,
      int version,
      ) async {
    await db.execute('''
      CREATE TABLE reports (
        id TEXT PRIMARY KEY,
        description TEXT NOT NULL,
        location TEXT NOT NULL,
        urgency TEXT NOT NULL,
        name_email TEXT,
        file_name TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(
      Database db,
      int oldVersion,
      int newVersion,
      ) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS reports'); // elvin added
      await _createDB(db, newVersion); // elvin added
      // 如果旧版本的 reports table 已经存在，
      // 根据你的旧结构进行升级。
      //
      // 如果开发阶段不需要保留旧资料，
      // 可以直接删除 App 数据，让 onCreate 重新建立。
    }
  }

  Future<void> insertReport(
      Map<String, dynamic> report,
      ) async {
    final db = await instance.database;

    await db.insert(
      'reports',
      report,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateReport(
      Map<String, dynamic> report,
      ) async {
    final db = await instance.database;

    await db.update(
      'reports',
      report,
      where: 'id = ?',
      whereArgs: [report['id']],
    );
  }

  Future<void> upsertReport(
      Map<String, dynamic> report,
      ) async {
    final db = await instance.database;

    await db.insert(
      'reports',
      report,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getReports() async {
    final db = await instance.database;

    return await db.query(
      'reports',
      orderBy: 'created_at DESC',
    );
  }

  Future<void> deleteReport(String id) async {
    final db = await instance.database;

    await db.delete(
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