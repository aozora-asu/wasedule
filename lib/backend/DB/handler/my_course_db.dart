import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import "../../../converter.dart";

class SyllabusQueryResult {
  String courseName;
  String classRoom;
  int? period;
  int? weekday;
  String? semester;
  int year;
  String? syllabusID;
  SyllabusQueryResult(
      {required this.courseName,
      required this.classRoom,
      required this.period,
      required this.weekday,
      required this.semester,
      required this.year,
      required this.syllabusID});
  Map<String, dynamic> toMap() {
    return {
      "courseName": courseName,
      "classRoom": classRoom,
      "semester": semester,
      "year": year,
      "syllabusID": syllabusID,
      "period": period,
      "weekday": weekday
    };
  }
}

class MoodleCourse {
  String courseName;
  String pageID;
  String color;
  String department;
  MoodleCourse(
      {required this.color,
      required this.courseName,
      required this.pageID,
      required this.department});

  Map<String, dynamic> toMap() {
    return {
      "courseName": courseName,
      "pageID": pageID,
      "color": color,
      "department": department
    };
  }
}

class MyCourse {
  String courseName;
  int? weekday;
  int? period;
  String? semester;
  String classRoom;
  String? memo;
  String color;
  int year;
  String? pageID;
  int? attendCount;
  String? syllabusID;
  String? criteria;

  MyCourse(
      {this.attendCount,
      required this.classRoom,
      required this.color,
      required this.courseName,
      this.memo,
      required this.pageID,
      required this.period,
      required this.semester,
      required this.syllabusID,
      required this.weekday,
      required this.year,
      required this.criteria});
  Map<String, dynamic> toMap() {
    return {
      "courseName": courseName,
      "weekday": weekday ?? -1,
      "period": period ?? -1,
      "semester": semester,
      "classRoom": classRoom,
      "memo": memo,
      "color": color,
      "attendCount": attendCount,
      "year": year,
      "pageID": pageID,
      "syllabusID": syllabusID ?? "",
      "criteria": criteria
    };
  }
}

class MyCourseDatabaseHandler {
  late Database _database;
  static const String databaseName = "my_course";
  static const String myCourseTable = "my_course";

  // データベースの初期化
  MyCourseDatabaseHandler() {
    _initMyCourseDatabase();
  }

  Future<void> _initMyCourseDatabase() async {
    String path = join(await getDatabasesPath(), '$databaseName.db');
    _database =
        await openDatabase(path, version: 1, onCreate: _createMyCourseDatabase);
  }

  // データベースの作成
  Future<void> _createMyCourseDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $myCourseTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        courseName TEXT,
        weekday INTEGER,
        period INTEGER,
        semester TEXT,
        classRoom TEXT,
        memo TEXT,
        color TEXT,
        attendCount INTEGER,
        year INTEGER,
        pageID TEXT,
        syllabusID TEXT,
        criteria TEXT,
        CONSTRAINT unique_course UNIQUE (year, period, weekday, semester,syllabusID)
      )
    ''');
  }

  Future<void> _insertMyCourse(MyCourse myCourse) async {
    await _database.insert(myCourseTable, myCourse.toMap());
  }

  Future<void> deleteMyCourse(int id) async {
    await _initMyCourseDatabase();
    await _database.delete(
      myCourseTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateMyCourse(int id, MyCourse newMyCourse) async {
    await _initMyCourseDatabase();
    await _database.update(
      myCourseTable,
      newMyCourse.toMap(), // 更新後の値
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateCourseName(int id, String newCourseName) async {
    await _initMyCourseDatabase();
    // データベースの更新
    await _database.update(
      myCourseTable,
      {'courseName': newCourseName}, // 新しいcourseNameの値を設定
      where: 'id = ?', // idによってレコードを特定
      whereArgs: [id], // idの値を指定
    );
  }

  Future<void> updateMemo(int id, String newMemo) async {
    await _initMyCourseDatabase();
    await _database.update(
      myCourseTable,
      {'memo': newMemo}, // 新しいmemoの値を設定
      where: 'id = ?', // idによってレコードを特定
      whereArgs: [id], // idの値を指定
    );
  }

  Future<void> updateClassRoom(int id, String newClassRoom) async {
    await _initMyCourseDatabase();
    await _database.update(
      myCourseTable,
      {'classRoom': newClassRoom}, // 新しいclassRoomの値を設定
      where: 'id = ?', // idによってレコードを特定
      whereArgs: [id], // idの値を指定
    );
  }

  Future<void> _updateMyCourseFromMoodle(MyCourse newMyCourse) async {
    await _initMyCourseDatabase();

    // MyCourseをMapに変換
    Map<String, dynamic> courseMap = newMyCourse.toMap();
    // "memo"キーと"attendCount"キーを削除
    courseMap.remove("memo");
    courseMap.remove("attendCount");

    // データベースを更新
    await _database.update(
      myCourseTable,
      courseMap,
      where:
          'year = ? AND weekday = ? AND period = ? AND semester = ? AND syllabusID=?',
      whereArgs: [
        newMyCourse.year,
        newMyCourse.weekday,
        newMyCourse.period,
        newMyCourse.semester,
        newMyCourse.syllabusID
      ],
    );
  }

  Future<void> resisterMyCourseFromMoodle(MyCourse myCourse) async {
    await _initMyCourseDatabase();
    try {
      await _insertMyCourse(myCourse);
    } catch (e) {
      // エラーが UNIQUE constraint failed の場合のみ無視する
      if (e.toString().contains("UNIQUE constraint failed")) {
        await _updateMyCourseFromMoodle(myCourse);
      }
    }
  }

  Future<List<Map<String, dynamic>>> getUniqueCourseNameAndPageIDList() async {
    await _initMyCourseDatabase();
    List<Map<String, dynamic>> result = await _database.query(
      myCourseTable,
      columns: ['DISTINCT courseName', 'pageID'],
    );

    return result;
  }

  Future<bool> hasMyCourse() async {
    int? count;
    // データのカウントを取得
    await _initMyCourseDatabase();
    count = Sqflite.firstIntValue(
        await _database.rawQuery('SELECT COUNT(*) FROM $myCourseTable'));

    return count! > 0;
  }

  Future<List<Map<String, dynamic>>?> getMyCourse() async {
    await _initMyCourseDatabase();

    List<Map<String, dynamic>> myCourseList = await _database.rawQuery('''
    SELECT 
      CASE WHEN weekday = -1 THEN NULL ELSE weekday END AS weekday,
      CASE WHEN period = -1 THEN NULL ELSE period END AS period,
      id,
      courseName,
      semester,
      classRoom,
      memo,
      color,
      attendCount,
      year,
      pageID,
      syllabusID,
      criteria
    FROM $myCourseTable
  ''');

    if (myCourseList.isEmpty) {
      return null;
    } else {
      return myCourseList;
    }
  }

  Future<List<Map<String, dynamic>>> getNextCourse() async {
    await _initMyCourseDatabase();
    DateTime now = DateTime.now();
    List<String> semesters = datetime2termList(now);

    List<Map<String, dynamic>> courses = await _database.query(myCourseTable,
        columns: [
          'CASE WHEN weekday = -1 THEN NULL ELSE weekday END AS weekday',
          'CASE WHEN period = -1 THEN NULL ELSE period END AS period',
          'id',
          'courseName',
          'semester',
          'classRoom',
          'memo',
          'color',
          'attendCount',
          'year',
          'pageID',
          'syllabusID',
          'criteria'
        ],
        where:
            'year = ? AND period = ? AND weekday = ? AND semester IN (${List.filled(semesters.length, '?').join(',')})',
        whereArgs: [
          datetime2schoolYear(now),
          datetime2Period(now.add(const Duration(minutes: 70))),
          now.weekday,
          ...semesters
        ]);

    return courses;
  }
}
