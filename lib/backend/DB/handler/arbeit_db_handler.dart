import 'package:flutter_calandar_app/backend/DB/models/tag.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:ui';

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
  Future<void> insertArbeit(Tag tag) async {
    await _initArbeitDatabase();
    await _database.insert('arbeit', tag.toMap());
  }

  // タスクの削除
  Future<int> deleteTag(int id) async {
    await _initArbeitDatabase();
    return await _database.delete(
      'arbeit',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateTag(Map<String, dynamic> newTag) async {
    await _initArbeitDatabase();
    await _database.update(
      'arbeit',
      newTag, // 更新後の値
      where: 'id = ?',
      whereArgs: [newTag["id"]],
    );
  }

  Future<void> resisterTagToDB(Map<String, dynamic> newTag) async {
    await _initArbeitDatabase();
    Tag tag;

    // 1. TaskItemオブジェクトを作成
   tag = Tag(
      title: newTag["title"],
      color: colorToInt(newTag["color"]),
      isBeit: newTag["isBeit"],
      wage: newTag["wage"]
      );
    await insertArbeit(tag);
  }

  Future<List<Map<String, dynamic>>> getTagFromDB() async {
    await _initArbeitDatabase();
    final List<Map<String, dynamic>> data =
        await _database.rawQuery('SELECT * FROM arbeit');
    return data;
  }

  
  // Color型からint型への変換関数
  int colorToInt(Color? color) {
    if (color == null){color = MAIN_COLOR;}
    // 16進数の赤、緑、青、アルファの値を結合して1つの整数に変換する
    return (color.alpha << 24) | (color.red << 16) | (color.green << 8) | color.blue;
  }


}
