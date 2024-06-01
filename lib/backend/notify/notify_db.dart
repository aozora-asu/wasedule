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
  //notifyFormat M/d etc
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
    _database = await openDatabase(
      path,
      version: 2,
      onCreate: _createNotifyDatabase,
      onUpgrade: _updateNotifyDatabase,
    );
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
        notifyType TEXT UNIQUE,
        weekday INT,
        time TEXT,
        days INTEGER,
        isValidNotify INTEGER
      )
    ''');
    await _addDefaultConfigData(db);
    await _addDefaultFormatData(db);
  }

  Future<void> _updateNotifyDatabase(
      Database db, int oldVersion, int newVersion) async {
    // データベースのバージョンごとのアップデート処理を行う
    if (oldVersion == 1) {
      // バージョン1からバージョン2へのアップデート処理
      // データが存在しない場合のみデフォルトのデータを挿入
      List<Map<String, dynamic>> config = await db.query(configTable);
      if (config.isEmpty) {
        await _addDefaultConfigData(db);
      }
      List<Map<String, dynamic>> format = await db.query(configTable);
      if (format.isEmpty) {
        await _addDefaultFormatData(db);
      }
    }
  }

  // デフォルトのデータを挿入するメソッド
  Future<void> _addDefaultConfigData(Database db) async {
    // config テーブルにデフォルトのデータを挿入
    await db.insert(
        configTable,
        NotifyConfig(
                notifyType: "daily",
                time: "08:00",
                isValidNotify: 1,
                days: 1,
                weekday: null)
            .toMap());
    await db.insert(
        configTable,
        NotifyConfig(
                notifyType: "beforeHour",
                time: "23:59",
                isValidNotify: 1,
                days: null,
                weekday: null)
            .toMap());
  }

  // デフォルトのデータを挿入するメソッド
  Future<void> _addDefaultFormatData(Database db) async {
    // config テーブルにデフォルトのデータを挿入
    await db.insert(formatTable,
        NotifyFormat(isContainWeekday: 1, notifyFormat: "M/d").toMap());
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

  Future<void> _updateNotifyConfig(NotifyConfig newNotifyConfig) async {
    await _database.update(
      configTable,
      newNotifyConfig.toMap(), // 更新後の値
      where: 'notifyType = ?',
      whereArgs: [newNotifyConfig.toMap()["notifyType"]],
    );
  }

  Future<void> activateNotify(int id) async {
    await _initNotifyDatabase();
    await _database.update(
      configTable,
      {'isValidNotify': 1}, // 更新後の値, // 更新後の値
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> disableNotify(int id) async {
    await _initNotifyDatabase();
    await _database.update(
      configTable,
      {'isValidNotify': 0}, // 更新後の値, // 更新後の値
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> _updateNotifyFormat(NotifyFormat newNotifyFormat) async {
    await _database.update(
      formatTable,
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
    try {
      await _insertNotifyConfig(notifyConfig);
    } catch (e) {
      // エラーが UNIQUE constraint failed の場合のみ無視する
      if (e.toString().contains("UNIQUE constraint failed")) {
        await _updateNotifyConfig(notifyConfig);
      }
    }
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
