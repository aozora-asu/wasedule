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
      "days": days,
      "isValidNotify": isValidNotify
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

  Future<void> _insertNotifyFormat(NotifyFormat notifyFormat) async {
    await _database.insert(formatTable, notifyFormat.toMap());
  }

  Future<void> _insertNotifyConfig(NotifyConfig notifyConfig) async {
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

  Future<void> updateNotifyConfig(NotifyConfig newNotifyConfig) async {
    await _initNotifyDatabase();
    await _database.update(
      configTable,
      newNotifyConfig.toMap(), // 更新後の値
      where: 'id = ?',
      whereArgs: [newNotifyConfig.toMap()["id"]],
    );
  }

  Future<void> _updateNotifyFormat(NotifyFormat newNotifyFormat) async {
    await _database.update(
      configTable,
      newNotifyFormat.toMap(), // 更新後の値
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<void> setNotifyFormat(NotifyFormat notifyFormat) async {
    await _initNotifyDatabase();
    if (await hasNotifyFormat()) {
      await _updateNotifyFormat(notifyFormat);
    } else {
      await _insertNotifyFormat(notifyFormat);
    }
  }

  Future<void> setNotifyConfig(NotifyConfig notifyConfig) async {
    await _initNotifyDatabase();
    await _insertNotifyConfig(notifyConfig);
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

  Future<List<Map<String, dynamic>>?> getNotifyConfigList() async {
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
