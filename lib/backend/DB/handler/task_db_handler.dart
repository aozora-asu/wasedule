import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/user_info_db_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

import "../../http_request.dart";

import '../../notify/notify_content.dart';

class TaskDatabaseHelper {
  late Database _database;
  // データベースの初期化
  TaskDatabaseHelper() {
    _initDatabase();
  }
  Future<void> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'task.db');
    _database = await openDatabase(path,
        version: 2, onCreate: _createDatabase, onUpgrade: _upgradeDatabase);
    await deleteExpairedTask(_database, 30);
  }

  Future<void> deleteExpairedTask(Database _database, int days) async {
    // 現在の日付を取得
    DateTime currentDate = DateTime.now();

    // 30日前の日付を計算
    DateTime thirtyDaysAgo = currentDate.subtract(Duration(days: days));

    // 30日前以前のタスクを削除するクエリを実行
    await _database.delete(
      'tasks',
      where: 'dtEnd <= ?',
      whereArgs: [thirtyDaysAgo.millisecondsSinceEpoch], // ミリ秒単位のエポック時間を使用
    );
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

  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS tasks_new(
       id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT UNIQUE, -- UNIQUE,
        title TEXT,
        dtEnd INTEGER,
        summary TEXT,
        description TEXT,
        isDone INTEGER
    )
  ''');
    // 既存のデータを新しいテーブルに移行
    var tasks = await db.query('tasks');
    int correctDateInt;
    for (var task in tasks) {
      if (task["uid"] == null) {
        correctDateInt = task["dtEnd"] as int;
      } else {
        DateTime correctDate =
            DateTime.fromMillisecondsSinceEpoch(task["dtEnd"] as int);
        correctDateInt = correctDate
            .subtract(const Duration(hours: 9))
            .millisecondsSinceEpoch;
      }
      await db.insert('tasks_new', {
        'uid': task["uid"],
        'title': task["title"],
        'dtEnd': correctDateInt,
        'summary': task["summary"],
        'description': task["description"],
        "isDone": task["isDone"],
      });
    }

    // 既存のテーブルを削除
    await db.execute('DROP TABLE tasks');

    // 新しいテーブルの名前を既存のテーブルの名前に変更
    await db.execute('ALTER TABLE tasks_new RENAME TO tasks');
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
    await NotifyContent().setNotify();
  }

  Future<void> updateDtEnd(int id, int newDtEnd) async {
    // 'tasks' テーブル内の特定の行を更新
    await _initDatabase();
    await _database.update(
      'tasks',
      {'dtEnd': newDtEnd}, // 更新後の値
      where: 'id = ?',
      whereArgs: [id],
    );
    await NotifyContent().setNotify();
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
    await NotifyContent().setNotify();
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
    await NotifyContent().setNotify();
  }

  Future<void> beDisplay(int id) async {
    // 'tasks' テーブル内の特定の行を更新
    await _initDatabase();
    await _database.update(
      'tasks',
      {'isDone': 0}, // 更新後の値
      where: 'id = ?',
      whereArgs: [id],
    );
  }

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
        title: taskData["events"][i]["CATEGORIES"] ?? "",
        isDone: 0,
      );
      // 2. データベースヘルパークラスを使用してデータベースに挿入
      try {
        await _database.insert('tasks', taskItem.toMap());
      } catch (e) {
        // エラーが UNIQUE constraint failed の場合のみ無視する
        if (e.toString().contains("UNIQUE constraint failed")) {}
      }
    }
    await NotifyContent().setNotify();
  }

  Future<void> resisterTaskListToDB(List<Map<String, dynamic>> taskList) async {
    await _initDatabase();
    for (var task in taskList) {
      try {
        TaskItem taskItem = TaskItem(
            title: task["title"],
            dtEnd: task["dtEnd"],
            isDone: task["isDone"],
            uid: task["uid"],
            description: task["description"],
            summary: task["summary"]);
        await _database.insert('tasks', taskItem.toMap());
      } catch (e) {
        // エラーが UNIQUE constraint failed の場合のみ無視する
        if (e.toString().contains("UNIQUE constraint failed")) {
          continue;
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> getDuringTaskList(
      int startDate, int endDate) async {
    await _initDatabase();
    List<Map<String, dynamic>> withinNdaysTask = await _database.query(
      'tasks',
      where: 'dtEnd > ? AND dtEnd <= ? AND isDone=?',
      whereArgs: [startDate, endDate, 0],
      orderBy: 'dtEnd ASC', // dtEndが小さい順に並び替える
    );
    return withinNdaysTask;
  }
}
