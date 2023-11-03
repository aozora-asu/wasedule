import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/task_item.dart';
import 'dart:io';

class TaskDatabaseHelper {
  late Database _database;

  TaskDatabaseHelper() {
    _initializeDatabase();
  }

  // データベースの初期化
  Future<void> _initializeDatabase() async {
    final File databaseFile = File('task.db');
    if (databaseFile.existsSync()) {
      databaseFile.deleteSync();
    }
    String path = join(await getDatabasesPath(), 'task.db');
    _database = await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  // データベースの作成
  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS items(
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
      return await _database.insert('items', task.toMap());
    } catch (e) {
      return 0;
    }
  }

  Future<void> deleteAllData(Database db) async {
    await db.rawDelete('DELETE FROM items');
  }

  // タスクの削除
  Future<int> deleteTask(int id) async {
    return await _database.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> taskListForTaskPage() async {
    final List<Map<String, dynamic>> dataList = await _database.query('items',
        columns: ['title', 'dtEnd', 'summary', 'description']); // 複数のカラムのデータを取得

    return dataList;
  }

  Future<List<Map<String, dynamic>>> taskListForCalendarPage() async {
    final List<Map<String, dynamic>> dataList = await _database.query('items',
        columns: ['title', 'dtEnd', 'summary']); // 複数のカラムのデータを取得

    return dataList;
  }

  Future<void> updateTitle(int id, String newTitle) async {
    // 'items' テーブル内の特定の行を更新
    await _database.update(
      'items',
      {'title': newTitle}, // 更新後の値
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateSummary(int id, String newSummary) async {
    // 'items' テーブル内の特定の行を更新
    await _database.update(
      'items',
      {'summary': newSummary}, // 更新後の値
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateDescription(int id, String newDescription) async {
    // 'items' テーブル内の特定の行を更新
    await _database.update(
      'items',
      {'description': newDescription}, // 更新後の値
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>> getTaskFromDB() async {
    var events = <String, dynamic>{};
    final List<Map<String, dynamic>> data =
        await _database.rawQuery('SELECT * FROM items');

    events["events"] = data;
    print(events);
    return events;
  }
}
