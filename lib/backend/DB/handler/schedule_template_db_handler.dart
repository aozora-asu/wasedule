import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/schedule_template.dart';


class ScheduleTemplateDatabaseHelper {
  late Database _database;
  // データベースの初期化
  ScheduleTemplateDatabaseHelper() {
    _initScheduleDatabase();
  }

  Future<void> _initScheduleDatabase() async {
    String path = join(await getDatabasesPath(), 'schedule_template.db');
    _database =
        await openDatabase(path, version: 1, onCreate: _createScheduleDatabase);
  }

  // データベースの作成
  Future<void> _createScheduleDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS schedule_template(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject TEXT,
        startTime TEXT,
        endTime TEXT,
        isPublic INTEGER, 
        publicSubject TEXT,
        tag TEXT
      )
    ''');
  }

  // データベースの初期化
  Future<void> insertSchedule(ScheduleTemplateItem schedule) async {
    await _initScheduleDatabase();
    await _database.insert('schedule_template', schedule.toMap());
  }

  // タスクの削除
  Future<int> deleteSchedule(int id) async {
    await _initScheduleDatabase();
    return await _database.delete(
      'schedule_template',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateSchedule(Map<String, dynamic> newSchedule) async {
    // 'tasks' テーブル内の特定の行を更新
    await _initScheduleDatabase();
    await _database.update(
      'schedule_template',
      newSchedule, // 更新後の値
      where: 'id = ?',
      whereArgs: [newSchedule["id"]],
    );
  }

  Future<void> resisterScheduleToDB(Map<String, dynamic> schedule) async {
    await _initScheduleDatabase();
    ScheduleTemplateItem scheduleItem;

    // 1. TaskItemオブジェクトを作成
    scheduleItem = ScheduleTemplateItem(
        subject: schedule["subject"],
        startTime: schedule["startTime"],
        endTime: schedule["endTime"],
        isPublic: schedule["isPublic"],
        publicSubject: schedule["publicSubject"],
        tag: schedule["tag"]);
    await insertSchedule(scheduleItem);
  }

  Future<List<Map<String, dynamic>>> getScheduleFromDB() async {
    await _initScheduleDatabase();
    final List<Map<String, dynamic>> data =
        await _database.rawQuery('SELECT * FROM schedule_template');
    return data;
  }
}
