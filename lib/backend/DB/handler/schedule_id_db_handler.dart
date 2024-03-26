import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import "../models/schedule_import_id.dart";

class ScheduleIDDatabaseHelper {
  late Database _database;
  // データベースの初期化
  ScheduleIDDatabaseHelper() {
    _initScheduleIDDatabase();
  }

  Future<void> _initScheduleIDDatabase() async {
    String path = join(await getDatabasesPath(), 'scheduleID.db');
    _database =
        await openDatabase(path, version: 1, onCreate: _createScheduleDatabase);
  }

  // データベースの作成
  Future<void> _createScheduleDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS scheduleID(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        scheduleID TEXT,
        tagID INTEGER
      )
    ''');
  }

  Future<void> insertScheduleID(Map<String, dynamic> scheduleIDItem) async {
    ScheduleIDItem schedule = ScheduleIDItem(
        scheduleID: scheduleIDItem["scheduleID"],
        tagID: scheduleIDItem["tagID"]);
    await _initScheduleIDDatabase();
    await _database.insert('scheduleID', schedule.toMap());
  }

  Future<int?> getTagIDByScheduleID(String scheduleID) async {
    await _initScheduleIDDatabase();
    // scheduleIDを指定してデータベースからtagIDを取得するクエリを実行
    List<Map<String, dynamic>> results = await _database.rawQuery('''
    SELECT tagID FROM scheduleID WHERE scheduleID = ?
  ''', [scheduleID]);

    // 結果が存在する場合は、最初の行のtagIDを返す
    if (results.isNotEmpty) {
      return results[0]['tagID'];
    } else {
      // 結果が存在しない場合はnullを返す
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getScheduleIDFromDB() async {
    await _initScheduleIDDatabase();
    final List<Map<String, dynamic>> data =
        await _database.rawQuery('SELECT * FROM scheduleID');

    return data;
  }
}
