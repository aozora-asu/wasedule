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
    String path = join(await getDatabasesPath(), 'user.db');
    _database = await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  // データベースの作成
  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $TABLE_NAME(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        url TEXT
      )
    ''');
  }

  // urlばりデートを行い、DBに追加できればtrue、追加できなければfalseを返す
  Future<bool> resisterUserInfo(String url) async {
    await _initDatabase();
    if (_isValidUrl(url)) {
      userInfo = UserInfo(url: url);
      return await _database.insert(TABLE_NAME, userInfo.toMap()) > 0;
    } else {
      return false;
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
