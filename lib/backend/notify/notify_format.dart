import 'package:flutter_calandar_app/backend/DB/models/arbeit.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class NotifyConfig {
  String notifyType;
  int? weekday;
  String time;
  int? days;
  NotifyConfig(
      {required this.notifyType, required this.time, this.days, this.weekday});

  toMap() {
    return {
      "notifyType": notifyType,
      "weekday": weekday,
      "time": time,
      "days": days
    };
  }
}

class NotifyFormat {
  String notifyFormat;
  int isContainWeekday;
  NotifyFormat({required this.isContainWeekday, required this.notifyFormat});

  toMap() {
    return {"isContainWeekday": isContainWeekday, "notifyFormat": notifyFormat};
  }
}

class NotifyDatabaseHandler {
  late Database _database;
  static const String databaseName = "notify";
  static const String format_table = "notify_format";
  static const String config_table = "notify_config";
  // データベースの初期化
  NotifyDatabaseHandler() {
    _initNotifyDatabase();
  }

  Future<void> _initNotifyDatabase() async {
    String path = join(await getDatabasesPath(), '$databaseName.db');
    _database =
        await openDatabase(path, version: 1, onCreate: _createNotifyDatabase);
  }

  // データベースの作成
  Future<void> _createNotifyDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $format_table(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        notifyFormat TEXT,
        isContainWeekday INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $config_table(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        notifyType TEXT,
        weekday INT,
        time TEXT,
        days INTEGER
      )
    ''');
  }

  Future<void> _insertNotifyFormat(Map<String, dynamic> notifyFormatMap) async {
    NotifyFormat notifyFormat = NotifyFormat(
        isContainWeekday: notifyFormatMap["isContainWeekday"],
        notifyFormat: notifyFormatMap["notifyFormat"]);
    await _database.insert(format_table, notifyFormat.toMap());
  }

  Future<void> insertNotifyConfig(Map<String, dynamic> notifyConfigMap) async {
    NotifyConfig notifyConfig = NotifyConfig(
        notifyType: notifyConfigMap["notifyType"],
        time: notifyConfigMap["time"],
        days: notifyConfigMap["days"],
        weekday: notifyConfigMap["weekday"]);
    await _initNotifyDatabase();
    await _database.insert(config_table, notifyConfig.toMap());
  }

  Future<void> deleteNotifyFormat(int id) async {
    await _initNotifyDatabase();
    await _database.delete(
      format_table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteNotifyConfig(int id) async {
    await _initNotifyDatabase();
    await _database.delete(
      config_table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateNotifyConfig(Map<String, dynamic> newNotifyConfig) async {
    await _initNotifyDatabase();
    await _database.update(
      config_table,
      newNotifyConfig, // 更新後の値
      where: 'id = ?',
      whereArgs: [newNotifyConfig["id"]],
    );
  }

  Future<void> _updateNotifyFormat(Map<String, dynamic> newNotifyFormat) async {
    await _database.update(
      config_table,
      newNotifyFormat, // 更新後の値
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<void> setNotifyFormat(Map<String, dynamic> notifyFormat) async {
    await _initNotifyDatabase();
    if (await hasNotifyFormat()) {
      await _updateNotifyFormat(notifyFormat);
    } else {
      await _insertNotifyFormat(notifyFormat);
    }
  }

  Future<bool> hasNotifyFormat() async {
    int? count;
    // データのカウントを取得
    await _initNotifyDatabase();
    count = Sqflite.firstIntValue(
        await _database.rawQuery('SELECT COUNT(*) FROM $format_table'));

    return count! > 0;
  }
}
