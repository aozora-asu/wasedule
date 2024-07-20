import 'package:flutter_calandar_app/backend/notify/notify_content.dart';
import 'package:flutter_calandar_app/backend/DB/sharepreference.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

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
  static const String configTableNew = "notify_config_new";
  // データベースの初期化
  NotifyDatabaseHandler() {
    _initNotifyDatabase();
  }
  Future<void> _initNotifyDatabase() async {
    String path = join(await getDatabasesPath(), '$databaseName.db');
    _database = await openDatabase(
      path,
      version: 3,
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
        notifyType TEXT ,
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
      List<Map<String, dynamic>> format = await db.query(formatTable);
      if (format.isEmpty) {
        await _addDefaultFormatData(db);
      }
    }
    if (oldVersion == 2) {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS $configTableNew(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        notifyType TEXT,
        weekday INT,
        time TEXT,
        days INTEGER,
        isValidNotify INTEGER
      )
    ''');
      // 既存のデータを新しいテーブルに移行
      var configs = await db.query(configTable);

      for (var config in configs) {
        await db.insert(configTableNew, {
          'notifyType': config["notifyType"],
          'weekday': config["weekday"],
          'time': config["time"] as String,
          'days': config["days"],
          'isValidNotify': config["isValidNotify"],
        });
      }
      // 既存のテーブルを削除
      await db.execute('DROP TABLE $configTable');
      // 新しいテーブルの名前を既存のテーブルの名前に変更
      await db.execute('ALTER TABLE $configTableNew RENAME TO $configTable');
      List<Map<String, dynamic>> config = await db.query(configTable);
      if (config.isEmpty) {
        await _addDefaultConfigData(db);
      }
      List<Map<String, dynamic>> format = await db.query(formatTable);
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
                time: "8:00",
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
    await _insertNotifyConfig(notifyConfig);
    await NotifyContent().setNotify(notifyConfig);
  }

  Future<bool> hasNotifyFormat() async {
    int? count;
    // データのカウントを取得
    await _initNotifyDatabase();
    count = Sqflite.firstIntValue(
        await _database.rawQuery('SELECT COUNT(*) FROM $formatTable'));

    return count! > 0;
  }

  Future<Map<String, dynamic>> getNotifyFormat() async {
    await _initNotifyDatabase();
    List<Map<String, dynamic>> notifyFormatList =
        await _database.rawQuery('SELECT * FROM $formatTable');

    return notifyFormatList[0];
  }

  Future<List<Map<String, dynamic>>?> getNotifyConfigList() async {
    await _initNotifyDatabase();
    List<Map<String, dynamic>> notifyConfigList = await _database
        .rawQuery("""SELECT * FROM $configTable ORDER BY notifyType ASC,
      weekday ASC,
      CASE
        WHEN LENGTH(time) = 4 THEN '0' || time -- H:mm -> 0H:mm
        ELSE time -- HH:mm -> HH:mm
      END ASC""");
    if (notifyConfigList.isEmpty) {
      return null;
    } else {
      return notifyConfigList;
    }
  }
}
