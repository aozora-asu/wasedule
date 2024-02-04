import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import "../../status_code.dart";
import "../../http_request.dart";
import '../models/user.dart';

class UserDatabaseHelper {
  late Database _database;
  // データベースの初期化
  UserDatabaseHelper() {
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'user.db');
    _database = await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  // データベースの作成
  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        url TEXT
      )
    ''');
  }

  // タスクの挿入
  Future<void> insertUserInfo(UserInfo userInfo) async {
    await _initDatabase();
    await _database.insert('user', userInfo.toMap());
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

  Future<bool> hasData() async {
    // データベースファイルのパスを取得します（パスはアプリ固有のものに変更してください）
    // データベース内のテーブル名
    String tableName = 'tasks';
    int? count;
    // データのカウントを取得
    await _initDatabase();
    count = Sqflite.firstIntValue(
        await _database.rawQuery('SELECT COUNT(*) FROM $tableName'));

    return count! > 0;
  }
}
