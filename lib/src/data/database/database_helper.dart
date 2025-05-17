import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:spiritual_meter/src/data/model/activity_log.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'spiritual_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE activity_logs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            activityType TEXT NOT NULL,
            durationInSeconds INTEGER NOT NULL,
            endTime TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertActivityLog(ActivityLog log) async {
    final db = await database;
    return await db.insert(
      'activity_logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ActivityLog>> getActivityLogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activity_logs',
      orderBy: 'endTime DESC',
      limit: 50,
    );
    return List.generate(maps.length, (i) {
      return ActivityLog.fromMap(maps[i]);
    });
  }

  Future<List<ActivityLog>> getActivityLogsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final String startIso = startDate.toIso8601String();
    final String endIso = endDate.toIso8601String();

    final List<Map<String, dynamic>> maps = await db.query(
      'activity_logs',
      where: 'endTime >= ? AND endTime <= ?',
      whereArgs: [startIso, endIso],
      orderBy: 'endTime DESC',
    );
    return List.generate(maps.length, (i) {
      return ActivityLog.fromMap(maps[i]);
    });
  }

  Future<int> deleteActivityLog(int id) async {
    final db = await database;
    return await db.delete('activity_logs', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ActivityLog>> getDailyLogs(DateTime date) async {
    final db = await database;
    final String start = DateTime(date.year, date.month, date.day).toIso8601String();
    final String end = DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();

    final List<Map<String, dynamic>> maps = await db.query(
      'activity_logs',
      where: 'endTime >= ? AND endTime <= ?',
      whereArgs: [start, end],
      orderBy: 'endTime DESC',
    );
    return List.generate(maps.length, (i) {
      return ActivityLog.fromMap(maps[i]);
    });
  }
}
