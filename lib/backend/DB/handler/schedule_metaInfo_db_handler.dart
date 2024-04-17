import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import "../models/schedule_meta_data.dart";
import 'dart:async';
import 'package:intl/intl.dart';

class ScheduleMetaDatabaseHelper {
  late Database _database;

  ScheduleMetaDatabaseHelper() {
    _initScheduleMetaDatabase();
  }

  Future<void> _initScheduleMetaDatabase() async {
    String path = join(await getDatabasesPath(), 'schedule_metaInfo.db');
    _database = await openDatabase(path, version: 1, onCreate: _createDatabase);
    await _deleteExpiredSchedules();
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

  Future<String?> getScheduleIDByTagID(String tagID) async {
    await _initScheduleMetaDatabase();
    List<Map<String, dynamic>> rows = await _database.query(
      'schedule_metaInfo',
      columns: ['scheduleID'],
      where: 'tagID = ?',
      whereArgs: [tagID],
      limit: 1, // 1行のみ取得
    );

    if (rows.isNotEmpty) {
      return rows.first['scheduleID'] as String?;
    } else {
      return null; // 合致する行が見つからなかった場合はnullを返す
    }
  }

  Future<void> _deleteExpiredSchedules() async {
    final formattedNow = DateFormat("yyyy-MM-dd HH:mm:ss")
        .format(DateTime.now()); // SQLiteの日付時刻形式に変換
    await _database.delete(
      'schedule_metaInfo',
      where: 'datetime(dtEnd) <= ?', // SQLiteのdatetime()関数を使用して日付時刻形式に変換
      whereArgs: [formattedNow],
    );
  }

  // データベースの初期化
  Future<void> _resisterScheduleMetaInfo(Map<String, dynamic> metaInfo) async {
    await _initScheduleMetaDatabase();
    ScheduleMetaInfo schedulemetaInfo = ScheduleMetaInfo(
        scheduleID: metaInfo["scheduleID"],
        scheduleType: metaInfo["scheduleType"],
        tagID: metaInfo["tagID"],
        dtEnd: metaInfo["dtEnd"]);
    await _database.insert('schedule_metaInfo', schedulemetaInfo.toMap());
  }

  Future<void> resisterSchedulemetaInfoListToDB(
      List<Map<String, dynamic>> metaInfoList) async {
    for (var metaInfo in metaInfoList) {
      try {
        await _resisterScheduleMetaInfo(metaInfo);
      } catch (e) {
        // エラーが UNIQUE constraint failed の場合のみ無視する
        if (e.toString().contains("UNIQUE constraint failed")) {
          continue;
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> getScheduleMetaInfoFromDB() async {
    await _initScheduleMetaDatabase();
    final List<Map<String, dynamic>> data =
        await _database.rawQuery('SELECT * FROM schedule_metaInfo');
    return data;
  }

  Future<void> importSchedule(Map<String, String?> importSchedule) async {
    await _initScheduleMetaDatabase();
    ScheduleMetaInfo scheduleMetaInfo = ScheduleMetaInfo(
        scheduleID: importSchedule["scheduleID"] as String,
        tagID: importSchedule["tagID"] as String,
        dtEnd: null,
        scheduleType: importSchedule["scheduleType"] as String);
    try {
      await _database.insert('schedule_metaInfo', scheduleMetaInfo.toMap());
    } catch (e) {
      // エラーが UNIQUE constraint failed の場合のみ無視する
      if (e.toString().contains("UNIQUE constraint failed")) {}
    }
  }

  Future<void> exportSchedule(Map<String, String> exportSchedule) async {
    await _initScheduleMetaDatabase();
    ScheduleMetaInfo scheduleMetaInfo = ScheduleMetaInfo(
        scheduleID: exportSchedule["scheduleID"] as String,
        tagID: exportSchedule["tagID"] as String,
        dtEnd: exportSchedule["dtEnd"] as String,
        scheduleType: exportSchedule["scheduleType"] as String);

    String scheduleID = exportSchedule['scheduleID'] as String;

    // 2. 同じ scheduleID を持つデータを検索します
    List<Map<String, dynamic>> existingData = await _database.query(
      'schedule_metaInfo',
      where: 'scheduleID = ?',
      whereArgs: [scheduleID],
    );

    // 3. 検索されたデータが存在するかどうかを確認します
    if (existingData.isEmpty) {
      // 検索されたデータが存在しない場合は、新しいデータとして挿入します
      await _database.insert('schedule_metaInfo', scheduleMetaInfo.toMap());
    } else {
      // 検索されたデータが存在する場合は、そのデータを更新します
      await _database.update(
        'schedule_metaInfo',
        exportSchedule,
        where: 'scheduleID = ?',
        whereArgs: [scheduleID],
      );
    }
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
