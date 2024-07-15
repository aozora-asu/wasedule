import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import "../../../converter.dart";
import "../../../constant.dart";
import 'package:intl/intl.dart';

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
  int? classNum;
  int? remainAbsent;

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
      required this.criteria,
      this.remainAbsent,
      this.classNum});
  Map<String, dynamic> toMap() {
    if (semester != null) {
      if (semester!.contains("quarter")) {
        classNum = 7;
        remainAbsent = 2;
      } else if (semester!.contains("semester")) {
        classNum = 14;
        remainAbsent = 4;
      } else if (semester!.contains("full_year")) {
        classNum = 28;
        remainAbsent = 8;
      }
    }

    return {
      "courseName": courseName,
      "weekday": weekday ?? -1,
      "period": period ?? -1,
      "semester": semester,
      "classRoom": classRoom,
      "memo": memo,
      "color": color,
      "remainAbsent": remainAbsent,
      "classNum": classNum,
      "year": year,
      "pageID": pageID,
      "syllabusID": syllabusID ?? "",
      "criteria": criteria
    };
  }
}

class AttendanceRecord {
  int myCourseID;
  AttendStatus attendStatus;
  String attendDate;

  AttendanceRecord(
      {required this.attendDate,
      required this.attendStatus,
      required this.myCourseID});
  toMap() {
    return {
      "myCourseID": myCourseID,
      "attendStatus": attendStatus.value,
      "attendDate": attendDate
    };
  }
}

class MyCourseDatabaseHandler {
  late Database _database;
  static const String databaseName = "my_course";
  static const String myCourseTable = "my_course";
  static const String myCourseTableNew = "my_course_new";
  static const String attendanceRecordTable = "attendance_record";

  // データベースの初期化
  MyCourseDatabaseHandler() {
    _initMyCourseDatabase();
  }

  Future<void> _initMyCourseDatabase() async {
    String path = join(await getDatabasesPath(), '$databaseName.db');
    _database = await openDatabase(path,
        version: 2,
        onCreate: _createMyCourseDatabase,
        onUpgrade: _upgradeMyCourseDatabase);
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
        classNum INTEGER,
        remainAbsent INTEGER,
        year INTEGER,
        pageID TEXT,
        syllabusID TEXT,
        criteria TEXT,
        CONSTRAINT unique_course UNIQUE (year, period, weekday, semester,syllabusID)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $attendanceRecordTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        myCourseID INTEGER,
        attendStatus TEXT,
        attendDate TEXT,
        CONSTRAINT unique_attend_record UNIQUE (myCourseID, attendDate)
      )
    ''');
  }

  Future<void> _upgradeMyCourseDatabase(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion == 1) {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS $myCourseTableNew(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        courseName TEXT,
        weekday INTEGER,
        period INTEGER,
        semester TEXT,
        classRoom TEXT,
        memo TEXT,
        color TEXT,
        classNum INTEGER,
        remainAbsent INTEGER,
        year INTEGER,
        pageID TEXT,
        syllabusID TEXT,
        criteria TEXT,
        CONSTRAINT unique_course UNIQUE (year, period, weekday, semester,syllabusID)
      )
    ''');
      // 既存のデータを新しいテーブルに移行
      var myCourseList = await db.query(myCourseTable);
      MyCourse myCourseClass;

      for (var myCourse in myCourseList) {
        myCourseClass = MyCourse(
          classRoom: myCourse["classRoom"] as String,
          color: myCourse["color"] as String,
          courseName: myCourse["courseName"] as String,
          pageID: myCourse["pageID"] as String,
          period: myCourse["period"] as int? ?? -1,
          semester: myCourse["semester"] as String,
          syllabusID: myCourse["syllabusID"] as String,
          weekday: myCourse["weekday"] as int? ?? -1,
          year: myCourse["year"] as int,
          criteria: myCourse["criteria"] as String?,
          memo: myCourse["memo"] as String?,
        );
        await db.insert(myCourseTableNew, myCourseClass.toMap());
      }

      // 既存のテーブルを削除
      await db.execute('DROP TABLE $myCourseTable');

      // 新しいテーブルの名前を既存のテーブルの名前に変更
      await db
          .execute('ALTER TABLE $myCourseTableNew RENAME TO $myCourseTable');
    }
    if (newVersion == 2) {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS $attendanceRecordTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        myCourseID INTEGER,
        attendStatus TEXT,
        attendDate TEXT,
        CONSTRAINT unique_attend_record UNIQUE (myCourseID, attendDate)
      )
    ''');
    }
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

  Future<void> updateClassNum(int id, int newClassNum) async {
    await _initMyCourseDatabase();
    await _database.update(
      myCourseTable,
      {'classNum': newClassNum}, // 新しいmemoの値を設定
      where: 'id = ?', // idによってレコードを特定
      whereArgs: [id], // idの値を指定
    );
  }

  Future<void> updateRemainAbsent(int id, int newRemainAbsent) async {
    await _initMyCourseDatabase();
    await _database.update(
      myCourseTable,
      {'remainAbsent': newRemainAbsent}, // 新しいmemoの値を設定
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
    courseMap.remove("classNum");
    courseMap.remove("remainAbsent");

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

  Future<List<Map<String, dynamic>>?> getAllMyCourse() async {
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
      classNum,
      remainAbsent,
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

  Future<List<Map<String, dynamic>>> getPresentTermCourseList() async {
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
          "classNum",
          "remainAbsent",
          'year',
          'pageID',
          'syllabusID',
          'criteria'
        ],
        where:
            'year = ? AND semester IN (${List.filled(semesters.length, '?').join(',')})',
        whereArgs: [datetime2schoolYear(now), ...semesters]);

    return courses;
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
          "classNum",
          "remainAbsent",
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

  Future<List<Map<String, dynamic>>> getAttendanceRecordFromDB(
      int myCourseID) async {
    await _initMyCourseDatabase();

    final List<Map<String, dynamic>> data = await _database.rawQuery("""
          SELECT * FROM $attendanceRecordTable
          WHERE myCourseID = ?
          """, [myCourseID]);

    return data;
  }

  Future<Map<String, dynamic>?> getAttendStatus(
      int myCourseID, String attendDate) async {
    await _initMyCourseDatabase();
    String formatedAttendDate =
        DateFormat("MM/dd").format(DateFormat("MM/dd").parse(attendDate));
    final List<Map<String, dynamic>> data = await _database.rawQuery("""
          SELECT * FROM $attendanceRecordTable
          WHERE myCourseID = ? AND attendDate = ?
          """, [myCourseID, formatedAttendDate]);
    if (data.isEmpty) {
      return null;
    } else {
      return data.first;
    }
  }

  Future<void> recordAttendStatus(AttendanceRecord attendanceRecord) async {
    await _initMyCourseDatabase();
    try {
      await _database.insert(attendanceRecordTable, attendanceRecord.toMap());
    } catch (e) {
      // エラーが UNIQUE constraint failed の場合のみ無視する
      if (e.toString().contains("UNIQUE constraint failed")) {
        await _database.update(
          attendanceRecordTable,
          // 更新後の値
          attendanceRecord.toMap(),
          where: 'myCourseID = ? AND attendDate = ?', // idによってレコードを特定
          whereArgs: [
            attendanceRecord.toMap()["myCourseID"],
            attendanceRecord.toMap()["attendDate"]
          ],
        );
      }
    }
  }

  Future<void> updateAttendRecord(
      int id, AttendanceRecord attendanceRecord) async {
    await _initMyCourseDatabase();
    await _database.update(
      attendanceRecordTable,
      attendanceRecord.toMap(),
      where: 'id = ?', // idによってレコードを特定
      whereArgs: [id], // idの値を指定
    );
  }

  Future<void> deleteAttendRecord(int id) async {
    await _initMyCourseDatabase();
    await _database.delete(
      attendanceRecordTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getAttendStatusCount(int myCourseID, AttendStatus status) async {
    await _initMyCourseDatabase();
    final List<Map<String, dynamic>> result = await _database.rawQuery('''
    SELECT COUNT(*) as attendCount
    FROM $attendanceRecordTable
    WHERE myCourseID = ? AND attendStatus = ?
  ''', [myCourseID, status.value]);
    return result.first['attendCount'] as int;
  }
}
