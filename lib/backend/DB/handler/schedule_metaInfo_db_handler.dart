import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import "../models/schedule_meta_data.dart";
import 'dart:async';

class ScheduleMetaDatabaseHelper {
  late Database _database;

  ScheduleMetaDatabaseHelper() {
    _initScheduleMetaDatabase();
  }

  Future<void> _initScheduleMetaDatabase() async {
    String path = join(await getDatabasesPath(), 'schedule_metaInfo.db');
    _database = await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS schedule_metaInfo(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        scheduleType TEXT,
        dtEnd TEXT,
        scheduleID TEXT UNIQUE,
        tagID TEXT
      )
    ''');
  }

  Future<void> importSchedule(Map<String, String> importSchedule) async {
    await _initScheduleMetaDatabase();
    ScheduleMetaInfo scheduleMetaInfo = ScheduleMetaInfo(
        scheduleID: importSchedule["scheduleID"] as String,
        tagID: importSchedule["tagID"] as String,
        dtEnd: importSchedule["dtEnd"] as String,
        scheduleType: importSchedule["scheduleType"] as String);
    await _database.insert('schedule_metaInfo', scheduleMetaInfo.toMap());
  }

  Future<void> exportSchedule(Map<String, String> exportSchedule) async {
    await _initScheduleMetaDatabase();
    ScheduleMetaInfo scheduleMetaInfo = ScheduleMetaInfo(
        scheduleID: exportSchedule["scheduleID"] as String,
        tagID: exportSchedule["tagID"] as String,
        dtEnd: exportSchedule["dtEnd"] as String,
        scheduleType: exportSchedule["scheduleType"] as String);
    await _database.insert('schedule_metaInfo', scheduleMetaInfo.toMap());
  }

  Future<List<Map<String, dynamic>>> getScheduleMetaInfoListByScheduleType(
      String scheduleType) async {
    await _initScheduleMetaDatabase();

    List<Map<String, dynamic>> records = await _database.query(
      'schedule_metaInfo',
      where: 'scheduleType = ?',
      whereArgs: [scheduleType],
    );

    return records;
  }
}
