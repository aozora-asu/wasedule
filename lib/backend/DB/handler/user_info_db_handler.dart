import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class UserDatabaseHelper {
  late Database _database;
  String TABLE_NAME = "user";
  late UserInfo userInfo;
  UserDatabaseHelper() {
    _initDatabase();
  }
  Future<void> _initDatabase() async {
    String path = join(await getDatabasesPath(), '$TABLE_NAME.db');
    _database = await openDatabase(path,
        version: 3, onCreate: _createDatabase, onUpgrade: _upgradeDatabase);
  }

  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS ${TABLE_NAME}_new(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
        url TEXT,
        backupID TEXT,
        dtEnd TEXT,
      tagID TEXT
    )
  ''');
    // 既存のデータを新しいテーブルに移行
    var userInfo = await db.query(TABLE_NAME);
    await db.insert("${TABLE_NAME}_new", {
      "url": userInfo.last["url"],
      "backupID": userInfo.last["backupID"],
      "dtEnd": userInfo.last["dtEnd"]
    });

    // 既存のテーブルを削除
    await db.execute('DROP TABLE $TABLE_NAME');

    // 新しいテーブルの名前を既存のテーブルの名前に変更
    await db.execute('ALTER TABLE ${TABLE_NAME}_new RENAME TO $TABLE_NAME');
  }

  // データベースの作成
  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $TABLE_NAME(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        url TEXT,
        backupID TEXT,
        dtEnd TEXT
      )
    ''');
  }

  // urlばりデートを行い、DBに追加できればtrue、追加できなければfalseを返す
  Future<bool> resisterUserInfo(String url) async {
    await _initDatabase();

    if (_isValidUrl(url)) {
      if (!await hasData()) {
        return await _database.insert(
              TABLE_NAME,
              {'url': url},
            ) >
            0;
      } else {
        return await _database.update(
              TABLE_NAME,
              {'url': url},
              where: 'id = ?',
              whereArgs: [1],
            ) >
            0;
      }
    } else {
      return false;
    }
  }

  Future<void> setBackupID(String backupID) async {
    await _initDatabase();
    if (!await hasData()) {
      await _database.insert(
        TABLE_NAME,
        {'backupID': backupID},
      );
    } else {
      await _database.update(
        TABLE_NAME,
        {'backupID': backupID},
        where: 'id = ?',
        whereArgs: [1],
      );
    }
  }

  Future<void> setExpireDate(String dtEnd) async {
    await _initDatabase();
    if (!await hasData()) {
      await _database.insert(
        TABLE_NAME,
        {'dtEnd': dtEnd},
      );
    } else {
      await _database.update(
        TABLE_NAME,
        {'dtEnd': dtEnd},
        where: 'id = ?',
        whereArgs: [1],
      );
    }
  }

  Future<String?> getUrl() async {
    await _initDatabase();
    List<Map<String, dynamic>> userInfo =
        await _database.rawQuery('SELECT * FROM user');
    if (userInfo.isEmpty) {
      return null;
    } else {
      return userInfo[0]["url"];
    }
  }

  Future<String?> getBackupID() async {
    await _initDatabase();
    List<Map<String, dynamic>> userInfo =
        await _database.rawQuery('SELECT * FROM user');
    if (userInfo.isEmpty) {
      return null;
    } else {
      return userInfo[0]["backupID"];
    }
  }

  Future<Map<String, String?>> getBackupInfo() async {
    await _initDatabase();
    List<Map<String, dynamic>> userInfo =
        await _database.rawQuery('SELECT * FROM user');
    if (userInfo.isEmpty) {
      return {"backupID": null, "dtEnd": null};
    } else {
      return {
        "backupID": userInfo[0]["backupID"],
        "dtEnd": userInfo[0]["dtEnd"]
      };
    }
  }

  Future<bool> hasData() async {
    int? count;
    // データのカウントを取得
    await _initDatabase();
    count = Sqflite.firstIntValue(
        await _database.rawQuery('SELECT COUNT(*) FROM $TABLE_NAME'));

    return count! > 0;
  }

  bool _isValidUrl(String url) {
    // 正規表現パターン
    String pattern =
        r'^https:\/\/wsdmoodle\.waseda\.jp\/calendar\/export_execute\.php\?userid=.*$';

    // 正規表現を作成
    RegExp regExp = RegExp(pattern);

    // 文字列が正規表現に一致するかどうかを確認
    return regExp.hasMatch(url);
  }
}
