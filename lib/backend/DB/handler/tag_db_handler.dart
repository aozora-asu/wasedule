import 'package:flutter_calandar_app/backend/DB/models/tag.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:async';

class TagDatabaseHelper {
  late Database _database;
  // データベースの初期化
  TagDatabaseHelper() {
    _initTagDatabase();
  }

  Future<void> _initTagDatabase() async {
    String path = join(await getDatabasesPath(), 'tag.db');
    _database = await openDatabase(path,
        version: 2,
        onCreate: _createTagDatabase,
        onUpgrade: _upgradeTagDatabase);
  }

  Future<void> _createTagDatabase(Database db, int version) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS tag(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      color INTEGER,
      isBeit INTEGER,
      wage INTEGER,
      fee INTEGER
    )
  ''');
  }

  Future<void> _upgradeTagDatabase(
      Database db, int oldVersion, int newVersion) async {
    // 新しい列を含む新しいテーブルを作成
    await db.execute('''
    CREATE TABLE IF NOT EXISTS tag_new(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tagID TEXT UNIQUE,
      title TEXT,
      color INTEGER,
      isBeit INTEGER,
      wage INTEGER,
      fee INTEGER
    )
  ''');

    // 既存のデータを新しいテーブルに移行
    var tags = await db.query('tag');
    for (var tag in tags) {
      await db.insert('tag_new', {
        'id': tag["id"],
        'tagID': (DateTime.now().microsecondsSinceEpoch + tag["id"].hashCode)
            .hashCode
            .toString(),
        'title': tag['title'],
        'color': tag['color'],
        'isBeit': tag['isBeit'],
        'wage': tag['wage'],
        'fee': tag['fee']
      });
    }

    // 既存のテーブルを削除
    await db.execute('DROP TABLE tag');

    // 新しいテーブルの名前を既存のテーブルの名前に変更
    await db.execute('ALTER TABLE tag_new RENAME TO tag');
  }

  Future<String?> getTagIDFromId(int id) async {
    await _initTagDatabase();
    List<Map<String, dynamic>> results = await _database.query(
      'tag',
      columns: ['tagID'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return results.first['tagID'] as String?;
    }
    return null; // 該当する id が見つからない場合は null を返す
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
        wage: newTag["wage"],
        fee: newTag["fee"]);
    await insertSchedule(tag);
  }

  Future<String> getTagName(int id) async {
    await _initTagDatabase();
    // 指定したIDに対応するタイトルを取得するクエリを実行し、結果を取得する
    List<Map<String, dynamic>> result = await _database.rawQuery('''
    SELECT title FROM tag WHERE id = ?
  ''', [id]);

    // 結果が存在しない場合はnullを返す
    if (result.isEmpty) {
      return "";
    }

    // 結果が存在する場合は、タイトルを取得して返す
    return result[0]['title'];
  }

  Future<List<Map<String, dynamic>>> getTagFromDB() async {
    await _initTagDatabase();
    final List<Map<String, dynamic>> data =
        await _database.rawQuery('SELECT * FROM tag');
    return data;
  }

  // Color型からint型への変換関数
  int colorToInt(Color? color) {
    if (color == null) {
      color = MAIN_COLOR;
    }
    // 16進数の赤、緑、青、アルファの値を結合して1つの整数に変換する
    return (color.alpha << 24) |
        (color.red << 16) |
        (color.green << 8) |
        color.blue;
  }
}
