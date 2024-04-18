import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/schedule.dart';
import './tag_db_handler.dart';
import 'package:intl/intl.dart';
import "./schedule_metaInfo_db_handler.dart";

class ScheduleDatabaseHelper {
  late Database _database;
  // データベースの初期化
  ScheduleDatabaseHelper() {
    _initScheduleDatabase();
  }

  Future<void> _initScheduleDatabase() async {
    String path = join(await getDatabasesPath(), 'schedule.db');
    _database = await openDatabase(path,
        version: 2,
        onCreate: _createScheduleDatabase,
        onUpgrade: _upgradeScheduleDatabase);
  }

  Future<void> _createScheduleDatabase(Database db, int version) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS schedule(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
       hash TEXT UNIQUE,
      subject TEXT,
      startDate TEXT,
      startTime TEXT,
      endDate TEXT,
      endTime TEXT,
      isPublic INTEGER, 
      publicSubject TEXT,
      tag TEXT,
      tagID TEXT
    )
  ''');
  }

  Future<void> _upgradeScheduleDatabase(
      Database db, int oldVersion, int newVersion) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS schedule_new(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      hash TEXT UNIQUE,
      subject TEXT,
      startDate TEXT,
      startTime TEXT,
      endDate TEXT,
      endTime TEXT,
      isPublic INTEGER, 
      publicSubject TEXT,
      tag TEXT,
      tagID TEXT
    )
  ''');
    // 既存のデータを新しいテーブルに移行
    var schedules = await db.query('schedule');
    if (oldVersion == 1) {
      for (var schedule in schedules) {
        String tagID = "";
        if (schedule["tag"] == "" || schedule["tag"] == null) {
          tagID = "";
        } else {
          int tagid = int.parse(schedule["tag"] as String);
          tagID = await TagDatabaseHelper().getTagIDFromId(tagid) ?? "";
        }

        await db.insert('schedule_new', {
          "subject": schedule['subject'],
          "startDate": schedule['startDate'],
          "startTime": schedule['startTime'],
          "endDate": schedule['endDate'],
          "endTime": schedule['endTime'],
          "isPublic": schedule['isPublic'],
          "publicSubject": schedule['publicSubject'],
          "tagID": tagID,
          "hash": (DateTime.now().microsecondsSinceEpoch +
                  schedules.indexOf(schedule).hashCode)
              .hashCode
              .toString()
        });
      }
    }

    // 既存のテーブルを削除
    await db.execute('DROP TABLE schedule');

    // 新しいテーブルの名前を既存のテーブルの名前に変更
    await db.execute('ALTER TABLE schedule_new RENAME TO schedule');
  }

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

    if (schedule["startDate"].contains("/")) {
      schedule["startDate"] = schedule["startDate"].replaceAll("/", "-");
    }
    if (schedule["endDate"] != null && schedule["endDate"].contains("/")) {
      schedule["endDate"] = schedule["endDate"].replaceAll("/", "-");
    }

    // 1. TaskItemオブジェクトを作成
    scheduleItem = ScheduleItem(
        subject: schedule["subject"],
        startDate: schedule["startDate"],
        startTime: schedule["startTime"] ?? "",
        endDate: schedule["endDate"],
        endTime: schedule["endTime"] ?? "",
        isPublic: schedule["isPublic"] ?? 1,
        publicSubject: schedule["publicSubject"],
        tagID: schedule["tagID"] ?? "",
        hash: schedule["hash"]);
    // 2. データベースヘルパークラスを使用してデータベースに挿入
    try {
      await insertSchedule(scheduleItem);
    } catch (e) {
      // エラーが UNIQUE constraint failed の場合のみ無視する
      if (e.toString().contains("UNIQUE constraint failed")) {
        await _database.update('schedule', scheduleItem.toMap(),
            where: 'hash = ?', whereArgs: [scheduleItem.toMap()["hash"]]);
      }
    }
  }

  Future<void> resisterScheduleListToDB(
      List<Map<String, dynamic>> scheduleList) async {
    for (var schedule in scheduleList) {
      await resisterScheduleToDB(schedule);
    }
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

  Future<List<Map<String, dynamic>>> pickScheduleByTag(String tagID) async {
    await _initScheduleDatabase();
    List<Map<String, dynamic>> postSchedule = await _database.query(
      'schedule',
      where: 'tagID = ?',
      whereArgs: [tagID],
    );
    return postSchedule;
  }

  Future<Map<String, dynamic>> getExportedSchedule() async {
    // List<Map<String, dynamic>> exportedScheduleList = [];
    Map<String, dynamic> exportedSchedule = {};
    List<Map<String, dynamic>> exportedScehduleMetaInfoList =
        await ScheduleMetaDatabaseHelper()
            .getScheduleMetaInfoListByScheduleType("export");
    for (var exportedScehduleMetaInfo in exportedScehduleMetaInfoList) {
      Map<String, dynamic> tagData = await TagDatabaseHelper()
          .getTagByTagID(exportedScehduleMetaInfo["tagID"]);
      List<Map<String, dynamic>> scheduleList =
          await pickScheduleByTag(exportedScehduleMetaInfo["tagID"]);
      Map<String, dynamic> scheduleInfo = {
        "tag": tagData,
        "schedule": scheduleList,
        "dtEnd": exportedScehduleMetaInfo["dtEnd"]
      };

      exportedSchedule[exportedScehduleMetaInfo["scheduleID"]] = scheduleInfo;
      //これは新バージョンで
      // Map<String, dynamic> exportedSchedule = {
      //   "scheduleID": exportedScehduleMetaInfo["scheduleID"],
      //   "tag": tag,
      //   "schedule": schedule,
      //   "dtEnd": exportedScehduleMetaInfo["dtEnd"]
      // };
      // exportedScehduleMetaInfoList.add(exportedSchedule);
    }

    return exportedSchedule;
  }
}
