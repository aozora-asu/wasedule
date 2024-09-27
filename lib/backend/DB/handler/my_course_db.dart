import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import "../../../static/constant.dart";
import 'package:intl/intl.dart';

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
  int? id;
  String courseName;
  DayOfWeek? weekday;
  Lesson? period;
  Term? semester;
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
  int? credit;
  String? subjectClassification;

  MyCourse(
      {this.id,
      required this.attendCount,
      required this.classRoom,
      required this.color,
      required this.courseName,
      required this.memo,
      required this.pageID,
      required this.period,
      required this.semester,
      required this.syllabusID,
      required this.weekday,
      required this.year,
      required this.criteria,
      required this.remainAbsent,
      required this.classNum,
      required this.subjectClassification,
      required this.credit});
  Map<String, dynamic> _toMap() {
    if (semester != null) {
      if (semester!.value.contains("quarter")) {
        classNum = 7;
        remainAbsent = 2;
      } else if (semester!.value.contains("semester")) {
        classNum = 14;
        remainAbsent = 4;
      } else if (semester!.value.contains("full_year")) {
        classNum = 28;
        remainAbsent = 8;
      }
    }

    return {
      //"id": id,
      "courseName": courseName,
      "weekday": weekday?.index ?? -1,
      "period": period?.period ?? -1,
      "semester": semester?.value,
      "classRoom": classRoom,
      "memo": memo,
      "color": color,
      "remainAbsent": remainAbsent,
      "classNum": classNum,
      "year": year,
      "pageID": pageID,
      "syllabusID": syllabusID,
      "criteria": criteria,
      "credit": credit,
      "subjectClassification": subjectClassification
    };
  }

  static const String databaseName = "my_course";
  static const String myCourseTable = "my_course";
  static const String myCourseTableNew = "my_course_new";
  static const String attendanceRecordTable = "attendance_record";

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), '$databaseName.db');
    return await openDatabase(path,
        version: 3,
        onCreate: _createMyCourseDatabase,
        onUpgrade: _upgradeMyCourseDatabase);
  }

  // データベースの作成
  static Future<void> _createMyCourseDatabase(Database db, int version) async {
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
        credit INTEGER,
        subjectClassification TEXT,
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

  static Future<void> _upgradeMyCourseDatabase(
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
        credit INTEGER,
        subjectClassification TEXT,
        CONSTRAINT unique_course UNIQUE (year, period, weekday, semester,syllabusID)
      )
    ''');
      // 既存のデータを新しいテーブルに移行
      var myCourseList = await db.query(myCourseTable);
      for (var myCourse in myCourseList) {
        await db.insert(myCourseTableNew, myCourse);
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
    if (newVersion == 3) {
      await db.execute('''
      ALTER TABLE $myCourseTable
      ADD COLUMN credit INTEGER
    ''');

      await db.execute('''
      ALTER TABLE $myCourseTable 
      ADD COLUMN subjectClassification TEXT
    ''');
    }
  }

  Future<void> resisterDB() async {
    final Database db = await _initDB();
    var map = _toMap();

    try {
      await db.insert(myCourseTable, map);
    } catch (e) {
      // エラーが UNIQUE constraint failed の場合のみ無視する
      if (e.toString().contains("UNIQUE constraint failed")) {
        await db.update(
          myCourseTable,
          map,
          where:
              'year = ? AND period = ? AND weekday = ? AND semester = ? AND syllabusID = ?',
          whereArgs: [
            map["year"],
            map["period"],
            map["weekday"],
            map["semester"],
            map["syllabusID"]
          ],
        );
      }
    }
  }

  static Future<void> deleteMyCourse(int id) async {
    final Database db = await _initDB();
    await db.delete(
      myCourseTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> updateMyCourse(int id, MyCourse newMyCourse) async {
    final Database db = await _initDB();
    await db.update(
      myCourseTable,
      newMyCourse._toMap(), // 更新後の値
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> updateCourseName(int id, String newCourseName) async {
    final Database db = await _initDB();
    // データベースの更新
    await db.update(
      myCourseTable,
      {'courseName': newCourseName}, // 新しいcourseNameの値を設定
      where: 'id = ?', // idによってレコードを特定
      whereArgs: [id], // idの値を指定
    );
  }

  static Future<void> updateColor(int id, String newColor) async {
    final Database db = await _initDB();
    // データベースの更新
    await db.update(
      myCourseTable,
      {'color': newColor}, // 新しいcolorの値を設定
      where: 'id = ?', // idによってレコードを特定
      whereArgs: [id], // idの値を指定
    );
  }

  static Future<void> updateMemo(int id, String newMemo) async {
    final Database db = await _initDB();
    await db.update(
      myCourseTable,
      {'memo': newMemo}, // 新しいmemoの値を設定
      where: 'id = ?', // idによってレコードを特定
      whereArgs: [id], // idの値を指定
    );
  }

  static Future<void> updateClassRoom(int id, String newClassRoom) async {
    final Database db = await _initDB();
    await db.update(
      myCourseTable,
      {'classRoom': newClassRoom}, // 新しいclassRoomの値を設定
      where: 'id = ?', // idによってレコードを特定
      whereArgs: [id], // idの値を指定
    );
  }

  static Future<void> updateClassNum(int id, int newClassNum) async {
    final Database db = await _initDB();
    await db.update(
      myCourseTable,
      {'classNum': newClassNum}, // 新しいmemoの値を設定
      where: 'id = ?', // idによってレコードを特定
      whereArgs: [id], // idの値を指定
    );
  }

  static Future<void> updateRemainAbsent(int id, int newRemainAbsent) async {
    final Database db = await _initDB();
    await db.update(
      myCourseTable,
      {'remainAbsent': newRemainAbsent}, // 新しいmemoの値を設定
      where: 'id = ?', // idによってレコードを特定
      whereArgs: [id], // idの値を指定
    );
  }

  static Future<List<Map<String, dynamic>>>
      getUniqueCourseNameAndPageIDList() async {
    final Database db = await _initDB();
    List<Map<String, dynamic>> result = await db.query(
      myCourseTable,
      columns: ['DISTINCT courseName', 'pageID'],
    );

    return result;
  }

  static Future<bool> hasMyCourse() async {
    int? count;
    // データのカウントを取得
    final Database db = await _initDB();
    count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $myCourseTable'));

    return count! > 0;
  }

  static Future<List<MyCourse>?> getAllMyCourse() async {
    final Database db = await _initDB();
    List<Map<String, dynamic>> myCourseList = await db.rawQuery('''
    SELECT * FROM $myCourseTable
  ''');
    if (myCourseList.isEmpty) {
      return null;
    } else {
      return myCourseList
          .map((e) => MyCourse(
              id: e["id"],
              attendCount: e["attendCount"],
              classRoom: e["classRoom"],
              color: e["color"],
              courseName: e["courseName"],
              memo: e["memo"],
              pageID: e["pageID"],
              period: e["period"] == -1 ? null : Lesson.atPeriod(e["period"]),
              semester:
                  e["semester"] == null ? null : Term.byValue(e["semester"]),
              syllabusID: e["syllabusID"],
              weekday:
                  e["weekday"] == -1 ? null : DayOfWeek.weekAt(e["weekday"]),
              year: e["year"],
              criteria: e["criteria"],
              remainAbsent: e["remainAbsent"],
              classNum: e["classNum"],
              subjectClassification: e["subjectClassification"],
              credit: e["credit"]))
          .toList();
    }
  }

  static Future<List<MyCourse>> getPresentTermCourseList() async {
    final Database db = await _initDB();
    DateTime now = DateTime.now();
    List<Term> semesters = Term.whenTerms(now);

    List<Map<String, dynamic>> courses = await db.query(myCourseTable,
        where:
            'year = ? AND semester IN (${List.filled(semesters.length, '?').join(',')})',
        whereArgs: [
          Term.whenSchoolYear(now),
          ...semesters.map((e) => e.value)
        ]);

    return courses
        .map((e) => MyCourse(
            id: e["id"],
            attendCount: e["attendCount"],
            classRoom: e["classRoom"],
            color: e["color"],
            courseName: e["courseName"],
            memo: e["memo"],
            pageID: e["pageID"],
            period: e["period"] == -1 ? null : Lesson.atPeriod(e["period"]),
            semester:
                e["semester"] == null ? null : Term.byValue(e["semester"]),
            syllabusID: e["syllabusID"],
            weekday: e["weekday"] == -1 ? null : DayOfWeek.weekAt(e["weekday"]),
            year: e["year"],
            criteria: e["criteria"],
            remainAbsent: e["remainAbsent"],
            classNum: e["classNum"],
            subjectClassification: e["subjectClassification"],
            credit: e["credit"]))
        .toList();
  }

  static Future<MyCourse?> getPresentTermFirstCourse(int weekday) async {
    final Database db = await _initDB();
    DateTime now = DateTime.now();
    List<Term> semesters = Term.whenTerms(now);

    List<Map<String, dynamic>> courses = await db.query(myCourseTable,
        where:
            'weekday = ? AND year = ? AND semester IN (${List.filled(semesters.length, '?').join(',')})',
        whereArgs: [
          weekday,
          Term.whenSchoolYear(now),
          ...semesters.map((e) => e.value)
        ],
        orderBy: "period ASC");

    return courses.isEmpty
        ? null
        : MyCourse(
            id: courses.first["id"],
            attendCount: courses.first["attendCount"],
            classRoom: courses.first["classRoom"],
            color: courses.first["color"],
            courseName: courses.first["courseName"],
            memo: courses.first["memo"],
            pageID: courses.first["pageID"],
            period: courses.first["period"] == -1
                ? null
                : Lesson.atPeriod(courses.first["period"]),
            semester: courses.first["semester"] == null
                ? null
                : Term.byValue(courses.first["semester"]),
            syllabusID: courses.first["syllabusID"],
            weekday: courses.first["weekday"] == -1
                ? null
                : DayOfWeek.weekAt(courses.first["weekday"]),
            year: courses.first["year"],
            criteria: courses.first["criteria"],
            remainAbsent: courses.first["remainAbsent"],
            classNum: courses.first["classNum"],
            subjectClassification: courses.first["subjectClassification"],
            credit: courses.first["credit"]);
  }

  static Future<bool> hasClass(int weekday, int period) async {
    final Database db = await _initDB();
    DateTime now = DateTime.now();
    List<Term> semesters = Term.whenTerms(now);

    List<Map<String, dynamic>> courses = await db.query(
      myCourseTable,
      where:
          'weekday = ? AND period= ? AND year = ? AND semester IN (${List.filled(semesters.length, '?').join(',')})',
      whereArgs: [
        weekday,
        period,
        Term.whenSchoolYear(now),
        ...semesters.map((e) => e.value)
      ],
    );

    return courses.isEmpty ? false : true;
  }

  static Future<List<MyCourse>> getNextCourse() async {
    final Database db = await _initDB();
    DateTime now = DateTime.now();
    List<Term> semesters = Term.whenTerms(now);

    List<Map<String, dynamic>> courses = await db.query(myCourseTable,
        where:
            'year = ? AND period = ? AND weekday = ? AND semester IN (${List.filled(semesters.length, '?').join(',')})',
        whereArgs: [
          Term.whenSchoolYear(now),
          Lesson.whenPeriod(now.add(const Duration(minutes: 70)))?.period,
          now.weekday,
          ...semesters.map((e) => e.value)
        ]);

    return courses
        .map((e) => MyCourse(
            id: e["id"],
            attendCount: e["attendCount"],
            classRoom: e["classRoom"],
            color: e["color"],
            courseName: e["courseName"],
            memo: e["memo"],
            pageID: e["pageID"],
            period: e["period"] == -1 ? null : Lesson.atPeriod(e["period"]),
            semester:
                e["semester"] == null ? null : Term.byValue(e["semester"]),
            syllabusID: e["syllabusID"],
            weekday: e["weekday"] == -1 ? null : DayOfWeek.weekAt(e["weekday"]),
            year: e["year"],
            criteria: e["criteria"],
            remainAbsent: e["remainAbsent"],
            classNum: e["classNum"],
            subjectClassification: e["subjectClassification"],
            credit: e["credit"]))
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getAttendanceRecordFromDB(
      int myCourseID) async {
    final Database db = await _initDB();

    final List<Map<String, dynamic>> data = await db.rawQuery("""
          SELECT * FROM $attendanceRecordTable
          WHERE myCourseID = ?
          """, [myCourseID]);

    return data;
  }

  static Future<Map<String, dynamic>?> getAttendStatus(
      int myCourseID, String attendDate) async {
    final Database db = await _initDB();
    String formatedAttendDate =
        DateFormat("MM/dd").format(DateFormat("MM/dd").parse(attendDate));
    final List<Map<String, dynamic>> data = await db.rawQuery("""
          SELECT * FROM $attendanceRecordTable
          WHERE myCourseID = ? AND attendDate = ?
          """, [myCourseID, formatedAttendDate]);
    if (data.isEmpty) {
      return null;
    } else {
      return data.first;
    }
  }

  static Future<void> recordAttendStatus(
      AttendanceRecord attendanceRecord) async {
    final Database db = await _initDB();

    try {
      await db.insert(attendanceRecordTable, attendanceRecord.toMap());
    } catch (e) {
      // エラーが UNIQUE constraint failed の場合のみ無視する
      if (e.toString().contains("UNIQUE constraint failed")) {
        await db.update(
          attendanceRecordTable,
          // 更新後の値
          attendanceRecord.toMap(),
          where: 'myCourseID = ? AND attendDate = ?',
          whereArgs: [
            attendanceRecord.toMap()["myCourseID"],
            attendanceRecord.toMap()["attendDate"]
          ],
        );
      }
    }
  }

  static Future<void> updateAttendRecord(
      int id, AttendanceRecord attendanceRecord) async {
    final Database db = await _initDB();
    await db.update(
      attendanceRecordTable,
      attendanceRecord.toMap(),
      where: 'id = ?', // idによってレコードを特定
      whereArgs: [id], // idの値を指定
    );
  }

  static Future<void> deleteAttendRecord(int id) async {
    final Database db = await _initDB();
    await db.delete(
      attendanceRecordTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> getAttendStatusCount(
      int myCourseID, AttendStatus status) async {
    final Database db = await _initDB();
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT COUNT(*) as attendCount
    FROM $attendanceRecordTable
    WHERE myCourseID = ? AND attendStatus = ?
  ''', [myCourseID, status.value]);
    return result.first['attendCount'] as int;
  }

  static Future<void> _updateMyCourseFromMoodle(MyCourse newMyCourse) async {
    final Database db = await _initDB();

    // MyCourseをMapに変換
    Map<String, dynamic> courseMap = newMyCourse._toMap();
    // "memo"キーと"attendCount"キーを削除
    courseMap.remove("memo");
    courseMap.remove("classNum");
    courseMap.remove("remainAbsent");

    // データベースを更新
    await db.update(
      myCourseTable,
      courseMap,
      where:
          'year = ? AND weekday = ? AND period = ? AND semester = ? AND syllabusID=?',
      whereArgs: [
        newMyCourse.year,
        newMyCourse.weekday?.index ?? -1,
        newMyCourse.period?.period ?? -1,
        newMyCourse.semester?.value,
        newMyCourse.syllabusID
      ],
    );
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
