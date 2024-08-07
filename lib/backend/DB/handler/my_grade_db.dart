import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MyGrade {
  int? id;
  String courseName;
  String majorClassification;
  String middleClassification;
  String? minorClassification;
  String year;
  String term;
  String credit;
  String grade;
  String? gradePoint;

  MyGrade(
      {this.id,
      required this.courseName,
      required this.credit,
      required this.grade,
      required this.term,
      required this.majorClassification,
      required this.middleClassification,
      required this.minorClassification,
      required this.year,
      required this.gradePoint});

  Map<String, dynamic> _toMap() {
    return {
      "id": id,
      "courseName": courseName,
      "majorClassification": majorClassification,
      "middleClassification": middleClassification,
      "minorClassification": minorClassification,
      "credit": credit,
      "grade": grade,
      "gradePoint": gradePoint,
      "year": year,
      "term": term
    };
  }

  static const String dbName = "myGrade";
  static const String tableName = "myGrade";

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), '$dbName.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  static Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        courseName TEXT,
        majorClassification TEXT,
        middleClassification TEXT,
        minorClassification TEXT,
        year TEXT,
        grade TEXT,
        gradePoint TEXT,
        credit TEXT,
        term TEXT,
        CONSTRAINT unique_course UNIQUE (year, courseName)
      )
    ''');
  }

  Future<void> resisterMyGrade() async {
    final Database db = await _initDB();
    try {
      await db.insert(tableName, _toMap());
    } catch (e) {
      // エラーが UNIQUE constraint failed の場合のみ無視する
      if (e.toString().contains("UNIQUE constraint failed")) {
        await db.update(
          tableName,
          _toMap(),
          where: 'id = ? ',
          whereArgs: [_toMap()["id"]],
        );
      }
    }
  }

  static Future<List<MyGrade>> getMyGrade() async {
    final Database db = await _initDB();
    final List<Map<String, dynamic>> data =
        await db.rawQuery('SELECT * FROM $tableName');
    return data
        .map((e) => MyGrade(
            id: e["id"],
            courseName: e["courseName"],
            credit: e["credit"],
            grade: e["grade"],
            gradePoint: e["gradePoint"],
            majorClassification: e["majorClassification"],
            middleClassification: e["middleClassification"],
            minorClassification: e["minorClassification"],
            year: e["year"],
            term: e["term"]))
        .toList();
  }
}
