import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/task_item.dart';

class TaskDatabaseHelper {
  late Database _database;
  // データベースの初期化
  Future<void> initDatabase() async {
    String path = join(await getDatabasesPath(), 'task_items.db');
    _database = await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  // データベースの作成
  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        summary TEXT,
        description TEXT,
        dtEnd INTEGER,
        categories TEXT,
        isDone INTEGER,
        memo TEXT
      )
    ''');
  }

  // タスクの挿入
  Future<int> insertTask(TaskItem task) async {
    return await _database.insert('items', task.toMap());
  }

  // すべてのタスクを取得
  Future<List<TaskItem>> getTasks() async {
    final List<Map<String, dynamic>> maps = await _database.query('items');
    return List.generate(maps.length, (i) {
      return TaskItem(
          summary: maps[i]['summary'],
          description: maps[i]['description'],
          dtEnd: DateTime.parse(maps[i]['dtEnd']).millisecondsSinceEpoch,
          categories: maps[i]['categories'],
          isDone: maps[i]['isDone'], // データベースの1をtrueにマップ
          memo: maps[i]["memo"]);
    });
  }

  // タスクの削除
  Future<int> deleteTask(int id) async {
    return await _database.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // データベース内のすべてのデータを表示
  Future<void> displayAllData() async {
    final List<Map<String, dynamic>> data =
        await _database.rawQuery('SELECT * FROM items');
    data.forEach((row) {
      print('ID: ${row['id']}');
      print('Summary: ${row['summary']}');
      print('Description: ${row['description']}');
      print('DtEnd: ${row['dtEnd']}');
      print('Categories: ${row['categories']}');
      print('IsDone: ${row['isDone']}');
      print('Memo: ${row['memo']}');
      print('-----------------------');
    });
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
