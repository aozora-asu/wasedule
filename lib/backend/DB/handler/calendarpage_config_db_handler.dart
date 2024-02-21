import 'package:flutter_calandar_app/backend/DB/models/arbeit.dart';
import 'package:flutter_calandar_app/backend/DB/models/calendar_config.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CalendarConfigDatabaseHelper {
  late Database _database;
  // データベースの初期化
 CalendarConfigDatabaseHelper() {
    _initCalendarConfigDatabase();
  }

  Future<void> _initCalendarConfigDatabase() async {
    String path = join(await getDatabasesPath(), 'calendar_config.db');
    _database =
        await openDatabase(path, version: 1, onCreate: _createCalendarConfigDatabase);
  }

  // データベースの作成
  Future<void> _createCalendarConfigDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS calendar_config(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        widgetName TEXT,
        isVisible INTEGER,
        info TEXT
      )
    ''');
  }

  // データベースの初期化
  Future<void> insertCalendarConfig(CalendarConfig config) async {
    await _initCalendarConfigDatabase();
    await _database.insert('calendar_config', config.toMap());
  }

  // タスクの削除
  Future<int> deleteConfig(int id) async {
    await _initCalendarConfigDatabase();
    return await _database.delete(
      'calendar_config',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateCalendarConfig(Map<String, dynamic> newConfig) async {
    await _initCalendarConfigDatabase();
    await _database.update(
      'calendar_config',
      newConfig,
      where: 'id = ?',
      whereArgs: [newConfig["id"]],
    );
  }

  Future<void> resisterConfigToDB(Map<String, dynamic> newConfig) async {
    await _initCalendarConfigDatabase();
    CalendarConfig config;

   config = CalendarConfig(
      widgetName: newConfig["widgetName"],
      isVisible: newConfig["isVisible"],
      info: newConfig["info"]
      );
    await insertCalendarConfig(config);
  }

  Future<List<Map<String, dynamic>>> getConfigFromDB() async {
    await _initCalendarConfigDatabase();
    final List<Map<String, dynamic>> data =
        await _database.rawQuery('SELECT * FROM calendar_config');
    return data;
  }

}
