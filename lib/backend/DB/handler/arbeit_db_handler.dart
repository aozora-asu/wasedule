import 'package:flutter_calandar_app/backend/DB/models/arbeit.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ArbeitDatabaseHelper {
  late Database _database;
  // データベースの初期化
  ArbeitDatabaseHelper() {
    _initArbeitDatabase();
  }

  Future<void> _initArbeitDatabase() async {
    String path = join(await getDatabasesPath(), 'arbeit.db');
    _database =
        await openDatabase(path, version: 1, onCreate: _createArbeitDatabase);
  }

  // データベースの作成
  Future<void> _createArbeitDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS arbeit(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tagId INTEGER,
        month TEXT,
        wage INTEGER
      )
    ''');
  }

  // データベースの初期化
  Future<void> insertArbeit(Arbeit arbeit) async {
    await _initArbeitDatabase();
    await _database.insert('arbeit', arbeit.toMap());
  }

  // タスクの削除
  Future<int> deleteArbeit(int id) async {
    await _initArbeitDatabase();
    return await _database.delete(
      'arbeit',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateArbeit(Map<String, dynamic> newArbeit) async {
    await _initArbeitDatabase();
    await _database.update(
      'arbeit',
      newArbeit, // 更新後の値
      where: 'id = ?',
      whereArgs: [newArbeit["id"]],
    );
  }

  Future<void> resisterArbeitToDB(Map<String, dynamic> newArbeit) async {
    await _initArbeitDatabase();
    Arbeit arbeit;

    // 1. TaskItemオブジェクトを作成
   arbeit = Arbeit(
      tagId: newArbeit["tagId"],
      month: newArbeit["month"],
      wage: newArbeit["wage"]
      );
    await insertArbeit(arbeit);
  }

  Future<List<Map<String, dynamic>>> getArbeitFromDB() async {
    await _initArbeitDatabase();
    final List<Map<String, dynamic>> data =
        await _database.rawQuery('SELECT * FROM arbeit');
    return data;
  }

}
