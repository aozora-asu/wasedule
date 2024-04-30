import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class NotifyConfig {
  String notifyType;
  int? weekday;
  String time;
  int? days;
  int isValidNotify;
  NotifyConfig(
      {required this.notifyType,
      required this.time,
      required this.isValidNotify,
      required this.days,
      required this.weekday});

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
  String? notifyFormat;
  int isContainWeekday;
  NotifyFormat({required this.isContainWeekday, required this.notifyFormat});

  toMap() {
    return {"isContainWeekday": isContainWeekday, "notifyFormat": notifyFormat};
  }
}

class NotifyDatabaseHandler {
  late Database _database;
  static const String databaseName = "notify";
  static const String formatTable = "notify_format";
  static const String configTable = "notify_config";
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
      CREATE TABLE IF NOT EXISTS $formatTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        notifyFormat TEXT,
        isContainWeekday INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $configTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        notifyType TEXT,
        weekday INT,
        time TEXT,
        days INTEGER,
        isValidNotify INTEGER
      )
    ''');
  }

  Future<void> _insertNotifyFormat(Map<String, dynamic> notifyFormatMap) async {
    NotifyFormat notifyFormat = NotifyFormat(
        isContainWeekday: notifyFormatMap["isContainWeekday"],
        notifyFormat: notifyFormatMap["notifyFormat"]);
    await _database.insert(formatTable, notifyFormat.toMap());
  }

  Future<void> _insertNotifyConfig(Map<String, dynamic> notifyConfigMap) async {
    NotifyConfig notifyConfig = NotifyConfig(
        notifyType: notifyConfigMap["notifyType"],
        time: notifyConfigMap["time"],
        isValidNotify: 1,
        days: notifyConfigMap["days"],
        weekday: notifyConfigMap["weekday"]);
    await _database.insert(configTable, notifyConfig.toMap());
  }

  Future<void> deleteNotifyFormat(int id) async {
    await _initNotifyDatabase();
    await _database.delete(
      formatTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteNotifyConfig(int id) async {
    await _initNotifyDatabase();
    await _database.delete(
      configTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateNotifyConfig(
      Map<String, dynamic> newNotifyConfigMap) async {
    await _initNotifyDatabase();
    await _database.update(
      configTable,
      newNotifyConfigMap, // 更新後の値
      where: 'id = ?',
      whereArgs: [newNotifyConfigMap["id"]],
    );
  }

  Future<void> _updateNotifyFormat(
      Map<String, dynamic> newNotifyFormatMap) async {
    await _database.update(
      configTable,
      newNotifyFormatMap, // 更新後の値
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<void> setNotifyFormat(Map<String, dynamic> notifyFormatMap) async {
    await _initNotifyDatabase();
    if (await hasNotifyFormat()) {
      await _updateNotifyFormat(notifyFormatMap);
    } else {
      await _insertNotifyFormat(notifyFormatMap);
    }
  }

  Future<void> setNotifyConfig(Map<String, dynamic> notifyConfigMap) async {
    await _initNotifyDatabase();
    await _insertNotifyConfig(notifyConfigMap);
  }

  Future<bool> hasNotifyFormat() async {
    int? count;
    // データのカウントを取得
    await _initNotifyDatabase();
    count = Sqflite.firstIntValue(
        await _database.rawQuery('SELECT COUNT(*) FROM $formatTable'));

    return count! > 0;
  }

  Future<Map<String, dynamic>?> getNotifyFormat() async {
    await _initNotifyDatabase();
    List<Map<String, dynamic>> notifyFormatList =
        await _database.rawQuery('SELECT * FROM $formatTable');
    if (notifyFormatList.isEmpty) {
      return null;
    } else {
      return notifyFormatList[0];
    }
  }

  Future<List<Map<String, dynamic>>?> getNotifyConfig() async {
    await _initNotifyDatabase();
    List<Map<String, dynamic>> notifyConfigList =
        await _database.rawQuery('SELECT * FROM $configTable');
    if (notifyConfigList.isEmpty) {
      return null;
    } else {
      return notifyConfigList;
    }
  }
}
