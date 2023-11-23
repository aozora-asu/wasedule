import 'package:flutter_calandar_app/backend/notify/notify_setting.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/task.dart';
import 'models/schedule.dart';
import "../status_code.dart";
import "../http_request.dart";
import 'package:intl/intl.dart';

class TaskDatabaseHelper {
  late Database _database;
  // データベースの初期化
  TaskDatabaseHelper() {
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'task.db');
    _database = await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  // データベースの作成
  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT UNIQUE, -- UNIQUE,
        title TEXT,
        dtEnd INTEGER,
        summary TEXT,
        description TEXT,
        isDone INTEGER
      )
    ''');
  }

  Future<void> _orderByDateTime() async {
    await _initDatabase();
    await _database.query(
      'tasks',
      orderBy: 'dtEnd ASC', // 日付で昇順にソート
    );
    _database.close();
  }

  // タスクの挿入
  Future<void> insertTask(TaskItem task) async {
    await _initDatabase();
    try {
      await _database.insert('tasks', task.toMap());
    } catch (e) {}
    await _orderByDateTime();
    _database.close();
  }

  Future<void> deleteAllData(Database db) async {
    await _initDatabase();
    await db.rawDelete('DELETE FROM tasks');
  }

  // タスクの削除
  Future<int> _deleteTask(int id) async {
    await _initDatabase();
    return await _database.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> taskListForTaskPage() async {
    await _initDatabase();

    final List<Map<String, dynamic>> dataList = await _database.query('tasks',
        orderBy: 'dtEnd ASC',
        columns: [
          'title',
          'dtEnd',
          'summary',
          'description',
          "isDone"
        ]); // 複数のカラムのデータを取得

    _database.close();
    return dataList;
  }

  Future<List<Map<String, dynamic>>> taskListForCalendarPage() async {
    await _initDatabase();
    final List<Map<String, dynamic>> dataList = await _database.query('tasks',
        orderBy: 'dtEnd ASC',
        columns: ['title', 'dtEnd', 'summary', 'isDone']); // 複数のカラムのデータを取得
    _database.close();
    return dataList;
  }

  Future<void> updateTitle(int id, String newTitle) async {
    // 'tasks' テーブル内の特定の行を更新
    await _initDatabase();
    await _database.update(
      'tasks',
      {'title': newTitle}, // 更新後の値
      where: 'id = ?',
      whereArgs: [id],
    );
    _database.close();
  }

  Future<void> updateSummary(int id, String newSummary) async {
    // 'tasks' テーブル内の特定の行を更新
    await _initDatabase();
    await _database.update(
      'tasks',
      {'summary': newSummary}, // 更新後の値
      where: 'id = ?',
      whereArgs: [id],
    );
    _database.close();
  }

  Future<void> updateDescription(int id, String newDescription) async {
    // 'tasks' テーブル内の特定の行を更新
    await _initDatabase();
    await _database.update(
      'tasks',
      {'description': newDescription}, // 更新後の値
      where: 'id = ?',
      whereArgs: [id],
    );
    _database.close();
  }

  Future<void> unDisplay(int id) async {
    // 'tasks' テーブル内の特定の行を更新
    await _initDatabase();
    await _database.update(
      'tasks',
      {'isDone': 1}, // 更新後の値
      where: 'id = ?',
      whereArgs: [id],
    );
    _database.close();
  }

  Future<void> deleteExpairedTask() async {}

  Future<List<Map<String, dynamic>>> getTaskFromDB() async {
    _initDatabase();
    await _orderByDateTime();
    final List<Map<String, dynamic>> data =
        await _database.rawQuery('SELECT * FROM tasks');
    _database.close();

    return data;
  }

  Future<bool> hasData() async {
    // データベースファイルのパスを取得します（パスはアプリ固有のものに変更してください）
    // データベース内のテーブル名
    String tableName = 'tasks';
    int? count;
    // データのカウントを取得
    await _initDatabase();
    count = Sqflite.firstIntValue(
        await _database.rawQuery('SELECT COUNT(*) FROM $tableName'));
    _database.close();
    return count! > 0;
  }

  Future<void> resisterTaskToDB(String urlString) async {
    // データベースヘルパークラスのインスタンスを作成

    // データベースの初期化
    Map<String, dynamic> taskData = await getTaskFromHttp(urlString);
    TaskItem taskItem;
    await _initDatabase();
    for (int i = 0; i < taskData["events"].length; i++) {
      // 1. TaskItemオブジェクトを作成
      taskItem = TaskItem(
        uid: taskData["events"][i]["UID"],
        summary: taskData["events"][i]["SUMMARY"],
        description: taskData["events"][i]["DESCRIPTION"],
        dtEnd: taskData["events"][i]["DTEND"],
        title: taskData["events"][i]["CATEGORIES"],
        isDone: STATUS_YET,
      );
      // 2. データベースヘルパークラスを使用してデータベースに挿入
      await insertTask(taskItem);
    }
    await _orderByDateTime();
    _database.close();
  }

  Future<List<Map<String, dynamic>>> withinNdaysTask() async {
    int n = 2;
    await initializeNotification();
    List<Map<String, dynamic>> withinNdaysTask = await _database.query(
      'tasks',
      where: 'dtEnd >= ? AND dtEnd < ?',
      whereArgs: [
        DateTime.now().millisecondsSinceEpoch,
        DateTime.now().add(Duration(days: n)).millisecondsSinceEpoch
      ],
    );
    _database.close();
    return withinNdaysTask;
  }
}

class ScheduleDatabaseHelper {
  late Database _database;
  // データベースの初期化

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
        startDate INTEGER,
        startTime INTEGER,
        endDate INTEGER,
        endTime INTEGER,
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
    _database.close();
  }

  Future<void> resisterScheduleToDB(Map<String, dynamic> schedule) async {
    await _initScheduleDatabase();
    ScheduleItem scheduleItem;
    for (int i = 0; i < schedule.length; i++) {
      // 1. TaskItemオブジェクトを作成
      scheduleItem = ScheduleItem(
          subject: schedule["subject"],
          startDate: DateTime.parse(schedule["startDate"].replaceAll('/', '-'))
                  .millisecondsSinceEpoch ~/
              1000,
          startTime: schedule["startTime"] != ""
              ? DateFormat("h:mm a").parse(schedule["startTime"]).hour * 3600 +
                  DateFormat("h:mm a").parse(schedule["startTime"]).minute *
                      60 +
                  DateFormat("h:mm a").parse(schedule["startTime"]).second
              : null,
          endDate: schedule["endDate"] != ""
              ? DateTime.parse(schedule["endDate"].replaceAll('/', '-'))
                      .millisecondsSinceEpoch ~/
                  1000
              : null,
          endTime: schedule["endTime"] != ""
              ? DateFormat("h:mm a").parse(schedule["endTime"]).hour * 3600 +
                  DateFormat("h:mm a").parse(schedule["endTime"]).minute * 60 +
                  DateFormat("h:mm a").parse(schedule["endTime"]).second
              : null,
          isPublic: schedule["isPublic"],
          publicSubject: schedule["publicSubject"],
          tag: schedule["tag"]);
      // 2. データベースヘルパークラスを使用してデータベースに挿入
      await insertSchedule(scheduleItem);
    }
    _database.close();
  }

  Future<List<Map<String, dynamic>>> getScheduleFromDB() async {
    await _initScheduleDatabase();
    final List<Map<String, dynamic>> data =
        await _database.rawQuery('SELECT * FROM schedule');
    _database.close();
    return data;
  }

  Future<List<Map<String, dynamic>>> _getTodaysSchedule() async {
    await _initScheduleDatabase();
    List<Map<String, dynamic>> todaysSchedule = await _database.query(
      'schedule',
      where: 'startDate = ?',
      whereArgs: [DateTime.now().millisecondsSinceEpoch ~/ 1000],
    );
    _database.close();
    return todaysSchedule;
  }

  Future<String> todaysScheduleForNotify() async {
    Future<List<Map<String, dynamic>>> todaysScheduleList =
        _getTodaysSchedule();

    late String todaysSchedule;
    List<Map<String, dynamic>> schedules = await todaysScheduleList;
    if (schedules.isEmpty) {
      todaysSchedule = "本日の予定はありません";
    } else {
      for (var schedule in schedules) {
        int startTimeInSeconds = schedule["startTime"] ?? 0; // 仮の初期値
        String endTimeString = schedule["endTime"] != null
            ? "${DateTime.fromMillisecondsSinceEpoch(schedule["endTime"] * 1000).hour}:${DateTime.fromMillisecondsSinceEpoch(schedule["endTime"] * 1000).minute}"
            : ""; // 仮の初期値
        String subject = schedule["subject"]; // null の場合はから文字列

        // int を DateTime に変換
        DateTime startTime =
            DateTime.fromMillisecondsSinceEpoch(startTimeInSeconds * 1000);
        // 24時間表記の文字列に変換
        String startTimeString = "${startTime.hour}:${startTime.minute}";

        todaysSchedule += "$startTimeString~$endTimeString  $subject\n";
      }
    }

    return todaysSchedule;
  }
}
