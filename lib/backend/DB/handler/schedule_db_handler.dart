import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import '../models/schedule.dart';

import 'package:intl/intl.dart';

class ScheduleDatabaseHelper {
  late Database _database;
  // データベースの初期化
  ScheduleDatabaseHelper() {
    _initScheduleDatabase();
  }

  Future<void> _initScheduleDatabase() async {
    String path = join(await getDatabasesPath(), 'schedule.db');
    _database =
        await openDatabase(path, version: 1, onCreate: _createScheduleDatabase);
  }

  // データベースの作成
  Future<void> _createScheduleDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS schedule(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject TEXT,
        startDate TEXT,
        startTime TEXT,
        endDate TEXT,
        endTime TEXT,
        isPublic INTEGER, 
        publicSubject TEXT,
        tag TEXT
      )
    ''');
  }

  // データベースの初期化
  Future<void> insertSchedule(ScheduleItem schedule) async {
    await _initScheduleDatabase();
    await _database.insert('schedule', schedule.toMap());
  }

  // タスクの削除
  Future<int> deleteSchedule(int id) async {
    await _initScheduleDatabase();
    return await _database.delete(
      'schedule',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateSchedule(Map<String, dynamic> newSchedule) async {
    // 'tasks' テーブル内の特定の行を更新
    await _initScheduleDatabase();
    await _database.update(
      'schedule',
      newSchedule, // 更新後の値
      where: 'id = ?',
      whereArgs: [newSchedule["id"]],
    );
  }

  Future<void> resisterScheduleToDB(Map<String, dynamic> schedule) async {
    await _initScheduleDatabase();
    ScheduleItem scheduleItem;

    // 1. TaskItemオブジェクトを作成
    scheduleItem = ScheduleItem(
        subject: schedule["subject"],
        startDate: schedule["startDate"].replaceAll("/", "-"),
        startTime: schedule["startTime"],
        endDate: schedule["endDate"].replaceAll("/", "-"),
        endTime: schedule["endTime"],
        isPublic: schedule["isPublic"],
        publicSubject: schedule["publicSubject"],
        tag: schedule["tag"]);
    await insertSchedule(scheduleItem);
  }

  Future<List<Map<String, dynamic>>> getScheduleFromDB() async {
    await _initScheduleDatabase();
    final List<Map<String, dynamic>> data =
        await _database.rawQuery('SELECT * FROM schedule');
    return data;
  }

  Future<List<Map<String, dynamic>>> _getTodaysSchedule(DateTime today) async {
    await _initScheduleDatabase();
    List<Map<String, dynamic>> todaysSchedule = await _database.query(
      'schedule',
      where: 'startDate = ?',
      whereArgs: [DateFormat("yyyy-MM-dd").format(today)],
    );

    return todaysSchedule;
  }

  Future<String> todaysScheduleForNotify(today) async {
    await _initScheduleDatabase();
    List<Map<String, dynamic>> todaysScheduleList =
        await _getTodaysSchedule(today);

    String todaysSchedule = "";

    if (todaysScheduleList.isEmpty) {
      todaysSchedule = "本日の予定はありません";
    } else {
      for (var schedule in todaysScheduleList) {
        String startTime = schedule["startTime"] ?? "";
        String endTime = schedule["endTime"] ?? "";
        String subject = schedule["subject"] ?? "";
        if (endTime == "" && startTime == "") {
          todaysSchedule += "終日の予定   $subject\n";
        } else {
          todaysSchedule += "$startTime~$endTime  $subject\n";
        }
      }
      todaysSchedule = todaysSchedule.trimRight();
    }

    return todaysSchedule;
  }

  Future<List<Map<String, dynamic>>> pickScheduleByTag(String tag) async {
    await _initScheduleDatabase();

    List<Map<String, dynamic>> postSchedule = await _database.query(
      'schedule',
      where: 'tag = ?',
      whereArgs: [tag],
    );

    return postSchedule;
  }
}
