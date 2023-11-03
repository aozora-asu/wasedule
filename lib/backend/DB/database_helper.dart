import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/task_item.dart';
import 'dart:io';

class TaskDatabaseHelper {
  late Database _database;
  // データベースの初期化
  Future<void> initDatabase() async {
    String path = join(await getDatabasesPath(), 'user.db');
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

  // タスクの挿入
  Future<int> insertTask(TaskItem task) async {
    try {
      //うまくいった場合のこと(通常処理)をかく
      return await _database.insert('tasks', task.toMap());
    } catch (e) {
      return 0;
    }
  }

  Future<void> deleteAllData(Database db) async {
    await db.rawDelete('DELETE FROM tasks');
  }

  // すべてのタスクを取得
  Future<List<TaskItem>> getTasks() async {
    final List<Map<String, dynamic>> maps = await _database.query('tasks');
    return List.generate(maps.length, (i) {
      return TaskItem(
        uid: maps[i]["uid"],
        summary: maps[i]['summary'],
        description: maps[i]['description'],
        dtEnd: DateTime.parse(maps[i]['dtEnd']).millisecondsSinceEpoch,
        title: maps[i]['title'],
        isDone: maps[i]['isDone'], // データベースの1をtrueにマップ
      );
    });
  }

  // タスクの削除
  Future<int> deleteTask(int id) async {
    return await _database.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> taskListForTaskPage() async {
    final List<Map<String, dynamic>> dataList = await _database.query('tasks',
        columns: ['title', 'dtEnd', 'summary', 'description']); // 複数のカラムのデータを取得

    return dataList;
  }

  Future<List<Map<String, dynamic>>> taskListForCalendarPage() async {
    final List<Map<String, dynamic>> dataList = await _database.query('tasks',
        columns: ['title', 'dtEnd', 'summary']); // 複数のカラムのデータを取得

    return dataList;
  }

  Future<void> updateTitle(int id, String newTitle) async {
    // 'tasks' テーブル内の特定の行を更新
    await _database.update(
      'tasks',
      {'title': newTitle}, // 更新後の値
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateSummary(int id, String newSummary) async {
    // 'tasks' テーブル内の特定の行を更新
    await _database.update(
      'tasks',
      {'summary': newSummary}, // 更新後の値
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateDescription(int id, String newDescription) async {
    // 'tasks' テーブル内の特定の行を更新
    await _database.update(
      'tasks',
      {'description': newDescription}, // 更新後の値
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>> getTaskFromDB() async {
    var events = <String, dynamic>{};
    final List<Map<String, dynamic>> data =
        await _database.rawQuery('SELECT * FROM tasks');

    events["events"] = data;
    return events;
  }
}
