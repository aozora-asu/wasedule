import 'package:sqflite/sqflite.dart';
import "dart:async";

import 'package:path/path.dart';

class DataBaseHelper {
  late Database database;

  // データベースの初期化
  Future<void> initializeDB() async {
    String path = await getDatabasesPath();
    database = await openDatabase(
      join(path, 'my_database.db'),
      onCreate: (db, version) async {
        await db.execute(
          '''CREATE TABLE IF NOT EXISTS my_table(
          date TEXT PRIMARY KEY, 
          time TEXT, 
          schedule TEXT, 
          plan TEXT, 
          record TEXT, 
          timeStamp TEXT)''',
        );
      },
      version: 1,
    );

    try {
      // 既存のテーブルがない場合、このクエリはエラーをスローする
      await database.rawQuery('SELECT * FROM my_table LIMIT 1');
    } catch (e) {
      // エラーが発生した場合はテーブルが存在しないとみなし、作成する
      await database.execute(
        '''CREATE TABLE IF NOT EXISTS my_table(date TEXT PRIMARY KEY, time TEXT, schedule TEXT, plan TEXT, record TEXT, timeStamp TEXT)''',
      );
    }
  }

  Future<void> insertNewData(String date, Duration time, String schedule,
      List<String> plan, List<String> record, List<DateTime> timeStamp) async {
    await initializeDB();
    String durationAsString =
        "${time.inHours}h${(time.inMinutes % 60).toString().padLeft(2, '0')}m";
    await database.insert(
      'my_table', // テーブル名
      {
        'date': date, // カラム名: 値
        'time': durationAsString,
        'schedule': schedule,
        'plan': plan.toString(),
        'record': record.toString(),
        'timeStamp': timeStamp.toString()
      },
    );
  }

  // テーブル内の全データを取得するメソッド
  Future<List<Map<String, dynamic>>> getAllDataFromMyTable() async {
    await initializeDB();
    return await database.rawQuery('SELECT * FROM my_table');
  }

  Future<List<Map<String, dynamic>>> getFixedData() async {
    List<Map<String, dynamic>> fixedDataList = await getAllDataFromMyTable();
    List<Map<String, dynamic>> result = [];
    for (int i = 0; i < fixedDataList.length; i++) {
      String durationAsString = fixedDataList[i]["time"];
      RegExp regex = RegExp(r'(\d+)h(\d+)m');
      Duration duration = const Duration(hours: 0, minutes: 0);
      RegExpMatch? match = regex.firstMatch(durationAsString);
      if (match != null) {
        int hours = int.parse(match.group(1)!);
        int minutes = int.parse(match.group(2)!);
        duration = Duration(hours: hours, minutes: minutes);
      }

      // 修正済みのMapオブジェクトを作成
      Map<String, dynamic> modifiedData = {
        ...fixedDataList[i], // 既存のデータをコピー
        "time": duration,
        "plan": stringToListString(fixedDataList[i]["plan"]),
        "record": stringToListString(fixedDataList[i]["record"]),
        "timeStamp": stringToListDateTime(fixedDataList[i]["timeStamp"]),
      };
      result.add(modifiedData);
    }

    return result;
  }

  Future<bool> hasData() async {
    // データベースファイルのパスを取得します（パスはアプリ固有のものに変更してください）
    // データベース内のテーブル名
    String tableName = 'my_table';
    int? count;
    // データのカウントを取得
    await initializeDB();
    count = Sqflite.firstIntValue(
        await database.rawQuery('SELECT COUNT(*) FROM $tableName'));

    return count! > 0;
  }

  List<dynamic> stringToListString(String target) {
    String newTarget = target.substring(1, target.length - 1);

    List<String> stringList = newTarget.split(',');

    // 空の場合の考慮
    if (stringList.isEmpty) {
      return [];
    } else {
      return stringList;
    }
  }

  List<dynamic> stringToListDateTime(String dateString) {
    String newdateString = dateString.substring(1, dateString.length - 1);
    List<String> dateStrings = newdateString.split(',');
    List<dynamic>? dateList = dateStrings.map((string) {
      try {
        return DateTime.parse(string.trim());
      } catch (e) {
        [];
      }
    }).toList();

    if (dateList.isEmpty) {
      return [];
    } else {
      return dateList;
    }
  }

  Future<void> upDateDB(String date, Duration time, String schedule,
      List<String> plan, List<String> record, List<DateTime?> timeStamp) async {
    await initializeDB();
    String durationAsString =
        "${time.inHours}h${(time.inMinutes % 60).toString().padLeft(2, '0')}m";
    Map<String, String> updateData = {
      "date": date,
      "time": durationAsString,
      "schedule": schedule,
      "plan": plan.toString(),
      "record": record.toString(),
      "timeStamp": timeStamp.toString()
    };
    await database
        .update('my_table', updateData, where: 'date = ?', whereArgs: [date]);
  }

  Future<void> resisterToDoListToDB(
      List<Map<String, dynamic>> toDoDataList) async {
    await initializeDB();
    for (var toDoData in toDoDataList) {
      database.insert("my_table", toDoData);
    }
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class TemplateDataBaseHelper {
  late Database templateDB;

  Future<void> initializeDB() async {
    String path = await getDatabasesPath();
    templateDB = await openDatabase(
      join(path, 'plan_template_database.db'),
      onCreate: (db, version) async {
        await db.execute(
          '''CREATE TABLE IF NOT EXISTS plan_template(template_index TEXT PRIMARY KEY, template TEXT)''',
        );
      },
      version: 1,
    );

    try {
      // 既存のテーブルがない場合、このクエリはエラーをスローする
      await templateDB.rawQuery('SELECT * FROM plan_template LIMIT 1');
    } catch (e) {
      // エラーが発生した場合はテーブルが存在しないとみなし、作成する
      await templateDB.execute(
        '''CREATE TABLE IF NOT EXISTS plan_template(template_index TEXT PRIMARY KEY, template TEXT)''',
      );
    }
  }

  Future<void> insertNewTemplateData(int index, String template) async {
    await initializeDB();
    String strIndex = index.toString();
    await templateDB.insert(
      'plan_template', // テーブル名
      {
        'template_index': strIndex, // カラム名: 値
        'template': template,
      },
    );
  }

  // テーブル内の全データを取得するメソッド
  Future<List<Map<String, Object?>>> getAllDataFromMyTable() async {
    await initializeDB();
    return await templateDB.rawQuery('SELECT * FROM plan_template');
  }

  Future<bool> hasData() async {
    // データベースファイルのパスを取得します（パスはアプリ固有のものに変更してください）
    // データベース内のテーブル名
    String tableName = 'plan_template';
    int? count;
    // データのカウントを取得
    await initializeDB();
    count = Sqflite.firstIntValue(
        await templateDB.rawQuery('SELECT COUNT(*) FROM $tableName'));

    return count! > 0;
  }

  Future<void> upDateDB(
    int index,
    String template,
  ) async {
    String strIndex = index.toString();
    await initializeDB();
    Map<String, Object?> updateData = {
      'template': template, // 列名に変更
    };
    await templateDB.update(
      'plan_template',
      updateData,
      where: 'template_index = ?',
      whereArgs: [strIndex],
    );
  }

  Future<void> deleteDB(int index, String template) async {
    String strIndex = index.toString();

    await templateDB.delete(
      'plan_template',
      where: 'id = ?',
      whereArgs: [strIndex], // "?"に代入する値
    );
  }

  Future<void> resisterToDoTemplateDB(
      List<Map<String, dynamic>> toDoTemplateDataList) async {
    await initializeDB();
    for (var toDoTemplateData in toDoTemplateDataList) {
      templateDB.insert("plan_template", toDoTemplateData);
    }
  }
}

// ////////以下はえぐざんぽー/////////////////////////////////////////////////////////////////////////////////////////////////////////


// class UserLocalDatabaseHelper {
//   late Database _database;
//   // データベースの初期化

//   UserLocalDatabaseHelper() {
//     _initDatabase();
//   }

//   Future<void> _initDatabase() async {
//     String path = join(await getDatabasesPath(), 'user.db');
//     _database = await openDatabase(path, version: 1, onCreate: _createDatabase);
//   }

//   // データベースの作成
//   Future<void> _createDatabase(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE IF NOT EXISTS user(
//         uid TEXT UNIQUE,
//         name TEXT,
//         imageUrl TEXT,
//         wayToPay TEXT,
//         info TEXT,
//         createAt INT
//       )
//     ''');
//   }

//   resisterUserInfoToLocal(String? uid, String name, Color imageUrl,
//       String wayToPay, String info) async {
//     await _initDatabase();
//     UserInfoForDB user = UserInfoForDB(
//         uid: uid,
//         name: name,
//         imageUrl: _colorToHex(imageUrl),
//         wayToPay: wayToPay,
//         info: info,
//         createAt: "${DateTime.now()}");
//     await _database.insert("user", user.toMap());
//   }

//   updateUserInfoToLocal(
//       {required String name,
//       required Color imageUrl,
//       required String wayToPay,
//       required String info}) async {
//     await _initDatabase();
//     Map<String, String> updateInfo = {
//       "name": name,
//       "imageUrl": _colorToHex(imageUrl),
//       "wayToPay": wayToPay,
//       "info": info,
//     };
//     await _database.update("user", updateInfo);
//   }

//   Future<Map<String, dynamic>?> getUserInfoFromLocalDB() async {
//     await _initDatabase();
//     final List<Map<String, dynamic>> data =
//         await _database.rawQuery('SELECT * FROM user LIMIT 1');
//     print(data);
//     print(data.isEmpty);

//     if (data.isEmpty) {
//       return null;
//     } else {
//       Map<String, dynamic> mutableUserInfo = Map.from(data[0]);
//       mutableUserInfo["imageUrl"] = _hexToColor(data[0]["imageUrl"]);
//       mutableUserInfo["wayToPay"] = mutableUserInfo["wayToPay"] ?? "";

//       mutableUserInfo["info"] = mutableUserInfo["info"] ?? "";

//       return mutableUserInfo;
//     }
//   }

// }