import 'package:flutter_calandar_app/backend/DB/models/tag.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:ui';

class TagDatabaseHelper {
  late Database _database;
  // データベースの初期化
  TagDatabaseHelper() {
    _initTagDatabase();
  }

  Future<void> _initTagDatabase() async {
    String path = join(await getDatabasesPath(), 'tag.db');
    _database =
        await openDatabase(path, version: 1, onCreate: _createTagDatabase);
  }

  // データベースの作成
  Future<void> _createTagDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tag(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        color INTEGER,
        isBeit INTEGER,
        wage INTEGER
      )
    ''');
  }

  // データベースの初期化
  Future<void> insertSchedule(Tag tag) async {
    await _initTagDatabase();
    await _database.insert('tag', tag.toMap());
  }

  // タスクの削除
  Future<int> deleteTag(int id) async {
    await _initTagDatabase();
    return await _database.delete(
      'tag',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateTag(Map<String, dynamic> newTag) async {
    await _initTagDatabase();
    await _database.update(
      'tag',
      newTag, // 更新後の値
      where: 'id = ?',
      whereArgs: [newTag["id"]],
    );
  }

  Future<void> resisterTagToDB(Map<String, dynamic> newTag) async {
    await _initTagDatabase();
    Tag tag;

    // 1. TaskItemオブジェクトを作成
   tag = Tag(
      title: newTag["title"],
      color: colorToInt(newTag["color"]),
      isBeit: newTag["isBeit"],
      wage: newTag["wage"]
      );
    await insertSchedule(tag);
  }

  Future<List<Map<String, dynamic>>> getTagFromDB() async {
    await _initTagDatabase();
    final List<Map<String, dynamic>> data =
        await _database.rawQuery('SELECT * FROM tag');
    return data;
  }

  
  // Color型からint型への変換関数
  int colorToInt(Color? color) {
    if (color == null){color = MAIN_COLOR;}
    // 16進数の赤、緑、青、アルファの値を結合して1つの整数に変換する
    return (color.alpha << 24) | (color.red << 16) | (color.green << 8) | color.blue;
  }


}
