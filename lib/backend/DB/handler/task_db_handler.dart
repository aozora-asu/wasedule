import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import "../../status_code.dart";
import "../../http_request.dart";

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
      orderBy: 'dtEnd ASC',
    );
  }

  // タスクの挿入
  Future<void> insertTask(TaskItem task) async {
    await _initDatabase();
    try {
      await _database.insert('tasks', task.toMap());
    } catch (e) {}
    await _orderByDateTime();
  }

  Future<void> deleteAllData(Database db) async {
    await _initDatabase();
    await db.rawDelete('DELETE FROM tasks');
  }

  Future<List<Map<String, dynamic>>> taskListForTaskPage() async {
    await _initDatabase();

    final List<Map<String, dynamic>> dataList = await _database.query('tasks',
        orderBy: 'dtEnd ASC',
        columns: [
          "id",
          'title',
          'dtEnd',
          'summary',
          'description',
          "isDone"
        ]); // 複数のカラムのデータを取得

    return dataList;
  }

  Future<List<Map<String, dynamic>>> taskListForCalendarPage() async {
    await _initDatabase();
    final List<Map<String, dynamic>> dataList = await _database.query('tasks',
        orderBy: 'dtEnd ASC',
        columns: [
          "id",
          'title',
          'dtEnd',
          'summary',
          'isDone'
        ]); // 複数のカラムのデータを取得

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
  }

  Future<void> deleteExpairedTask() async {}

  Future<List<Map<String, dynamic>>> getTaskFromDB() async {
    _initDatabase();
    await _orderByDateTime();
    final List<Map<String, dynamic>> data =
        await _database.rawQuery('SELECT * FROM tasks');

    return data;
  }

  Future<bool> hasData() async {
    // データベースファイルのパスを取得します（パスはアプリ固有のものに変更してください）
    // データベース内のテーブル名
    String tableName = 'tasks';
    int? count;

    // データのカウントを取得
    await _initDatabase();

    count = Sqflite.firstIntValue(await _database
        .rawQuery('SELECT COUNT(*) FROM $tableName WHERE isDone = 0'));

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
  }

  Future<void> resisterTaskListToDB(List<Map<String, dynamic>> taskList) async {
    for (var task in taskList) {
      try {
        TaskItem taskItem = TaskItem(
            title: task["title"],
            dtEnd: task["dtEnd"],
            isDone: task["isDone"],
            uid: task["uid"],
            description: task["description"],
            summary: task["summary"]);
        await insertTask(taskItem);
      } catch (e) {
        // エラーが UNIQUE constraint failed の場合のみ無視する
        if (e.toString().contains("UNIQUE constraint failed")) {
          continue;
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> withinNdaysTask(
      DateTime today, int n) async {
    await _initDatabase();
    List<Map<String, dynamic>> withinNdaysTask = await _database.query(
      'tasks',
      where: 'dtEnd >= ? AND dtEnd < ? AND isDone=?',
      whereArgs: [
        today.millisecondsSinceEpoch,
        today.add(Duration(days: n)).millisecondsSinceEpoch,
        0
      ],
    );

    return withinNdaysTask;
  }

  Future<String> taskDueTodayForNotify(DateTime today) async {
    await _initDatabase();
    List<Map<String, dynamic>> taskDueTodayList =
        await withinNdaysTask(today, 1);
    late String taskDueToday = "";
    if (taskDueTodayList.isEmpty) {
      taskDueToday = "本日が期限の課題はありません";
    } else {
      for (var task in taskDueTodayList) {
        String due = "";
        if (task["isDone"] == 0) {
          try {
            due = DateFormat("HH:mm")
                .format(DateTime.fromMillisecondsSinceEpoch(task["dtEnd"]));
          } catch (e) {
            due = "";
          }
          String title = task["title"] ?? "";
          String summary = task["summary"] ?? "";
          taskDueToday += "$dueまで $title   $summary\n";
        }
      }
    }

    taskDueToday = taskDueToday.trimRight(); // Trim trailing whitespaces

    return taskDueToday;
  }
}
