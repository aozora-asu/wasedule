import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/moodle_view_page.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import "../sharepreference.dart";

class MyGradeDB {
  static const String dbName = "myGrade.db";
  static const String majorClassTable = 'MajorClass';
  static const String middleClassTable = 'MiddleClass';
  static const String minorClassTable = 'MinorClass';
  static const String myGradeTable = 'MyGrade';

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), dbName);
    return await openDatabase(path,
        version: 1, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  static Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $majorClassTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT UNIQUE,
        requiredCredit INTEGER,
        acquiredCredit INTEGER,
        countedCredit INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $middleClassTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        majorClassId INTEGER,
        text TEXT UNIQUE,
        requiredCredit INTEGER,
        acquiredCredit INTEGER,
        countedCredit INTEGER,
        FOREIGN KEY(majorClassId) REFERENCES $majorClassTable(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $minorClassTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        middleClassId INTEGER,
        text TEXT UNIQUE,
        requiredCredit INTEGER,
        acquiredCredit INTEGER,
        countedCredit INTEGER,
        FOREIGN KEY(middleClassId) REFERENCES $middleClassTable(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS $myGradeTable (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    minorClassId INTEGER,
    middleClassId INTEGER,
    courseName TEXT,
    year TEXT,
    term TEXT,
    credit INTEGER,
    grade TEXT,
    gradePoint TEXT,
    FOREIGN KEY(minorClassId) REFERENCES $minorClassTable(id) ON DELETE CASCADE,
    FOREIGN KEY(middleClassId) REFERENCES $middleClassTable(id) ON DELETE CASCADE,
    CONSTRAINT unique_course UNIQUE (courseName, year)
  )
''');
  }

  static Future<void> _upgradeDB(
      Database db, int oldVersion, int newVersion) async {}

  Future<void> insertMajorClass(MajorClass majorClass) async {
    final db = await _initDB();

    try {
      majorClass.id = await db.insert(majorClassTable, {
        'text': majorClass.text,
        'requiredCredit': majorClass.requiredCredit,
        'acquiredCredit': majorClass.acquiredCredit,
        'countedCredit': majorClass.countedCredit,
      });
    } catch (e) {
      // エラーが UNIQUE constraint failed の場合のみ無視する
      if (e.toString().contains("UNIQUE constraint failed")) {
        await db.update(
          majorClassTable,
          {
            'text': majorClass.text,
            'requiredCredit': majorClass.requiredCredit,
            'acquiredCredit': majorClass.acquiredCredit,
            'countedCredit': majorClass.countedCredit,
          },
          where: 'text = ?',
          whereArgs: [majorClass.text],
        );

        // 更新後のidを取得
        List<Map<String, dynamic>> result = await db.query(
          majorClassTable,
          where: 'text = ?',
          whereArgs: [majorClass.text],
        );

        if (result.isNotEmpty) {
          majorClass.id = result.first['id'];
        }
      }
    }

    for (MiddleClass middleClass in majorClass.middleClass) {
      try {
        middleClass.id = await db.insert(middleClassTable, {
          'majorClassId': majorClass.id,
          'text': middleClass.text,
          'requiredCredit': middleClass.requiredCredit,
          'acquiredCredit': middleClass.acquiredCredit,
          'countedCredit': middleClass.countedCredit,
        });
      } catch (e) {
        // エラーが UNIQUE constraint failed の場合のみ無視する
        if (e.toString().contains("UNIQUE constraint failed")) {
          await db.update(
            middleClassTable,
            {
              'majorClassId': majorClass.id,
              'text': middleClass.text,
              'requiredCredit': middleClass.requiredCredit,
              'acquiredCredit': middleClass.acquiredCredit,
              'countedCredit': middleClass.countedCredit,
            },
            where: 'text = ?',
            whereArgs: [middleClass.text],
          );

          // 更新後のidを取得
          List<Map<String, dynamic>> result = await db.query(
            middleClassTable,
            where: 'text = ?',
            whereArgs: [middleClass.text],
          );

          if (result.isNotEmpty) {
            middleClass.id = result.first['id'];
          }
        }
      }
      for (MyGrade myGrade in middleClass.myGrade) {
        try {
          myGrade.id = await db.insert(myGradeTable, {
            'middleClassId': middleClass.id,
            'minorClassId': null,
            'courseName': myGrade.courseName,
            'year': myGrade.year,
            'term': myGrade.term,
            'credit': myGrade.credit,
            'grade': myGrade.grade,
            'gradePoint': myGrade.gradePoint,
          });
        } catch (e) {
          // エラーが UNIQUE constraint failed の場合のみ無視する
          if (e.toString().contains("UNIQUE constraint failed")) {
            await db.update(
              myGradeTable,
              {
                'middleClassId': middleClass.id,
                'minorClassId': null,
                'courseName': myGrade.courseName,
                'year': myGrade.year,
                'term': myGrade.term,
                'credit': myGrade.credit,
                'grade': myGrade.grade,
                'gradePoint': myGrade.gradePoint,
              },
              where: 'year = ? AND courseName = ? ',
              whereArgs: [myGrade.year, myGrade.courseName],
            );

            // 更新後のidを取得
            List<Map<String, dynamic>> result = await db.query(
              myGradeTable,
              where: 'year = ? AND courseName = ?',
              whereArgs: [myGrade.year, myGrade.courseName],
            );

            if (result.isNotEmpty) {
              myGrade.id = result.first['id'];
            }
          }
        }
      }

      for (MinorClass minorClass in middleClass.minorClass) {
        try {
          minorClass.id = await db.insert(minorClassTable, {
            'middleClassId': middleClass.id,
            'text': minorClass.text,
            'requiredCredit': minorClass.requiredCredit,
            'acquiredCredit': minorClass.acquiredCredit,
            'countedCredit': minorClass.countedCredit,
          });
        } catch (e) {
          // エラーが UNIQUE constraint failed の場合のみ無視する
          if (e.toString().contains("UNIQUE constraint failed")) {
            await db.update(
              minorClassTable,
              {
                'middleClassId': middleClass.id,
                'text': minorClass.text,
                'requiredCredit': minorClass.requiredCredit,
                'acquiredCredit': minorClass.acquiredCredit,
                'countedCredit': minorClass.countedCredit,
              },
              where: 'text = ?',
              whereArgs: [minorClass.text],
            );

            // 更新後のidを取得
            List<Map<String, dynamic>> result = await db.query(
              minorClassTable,
              where: 'text = ?',
              whereArgs: [minorClass.text],
            );

            if (result.isNotEmpty) {
              minorClass.id = result.first['id'];
            }
          }
        }

        for (MyGrade myGrade in minorClass.myGrade) {
          try {
            myGrade.id = await db.insert(myGradeTable, {
              'middleClassId': null,
              'minorClassId': minorClass.id,
              'courseName': myGrade.courseName,
              'year': myGrade.year,
              'term': myGrade.term,
              'credit': myGrade.credit,
              'grade': myGrade.grade,
              'gradePoint': myGrade.gradePoint,
            });
          } catch (e) {
            // エラーが UNIQUE constraint failed の場合のみ無視する
            if (e.toString().contains("UNIQUE constraint failed")) {
              await db.update(
                myGradeTable,
                {
                  'middleClassId': null,
                  'minorClassId': minorClass.id,
                  'courseName': myGrade.courseName,
                  'year': myGrade.year,
                  'term': myGrade.term,
                  'credit': myGrade.credit,
                  'grade': myGrade.grade,
                  'gradePoint': myGrade.gradePoint,
                },
                where: 'year = ? AND courseName = ? ',
                whereArgs: [myGrade.year, myGrade.courseName],
              );

              // 更新後のidを取得
              List<Map<String, dynamic>> result = await db.query(
                myGradeTable,
                where: 'year = ? AND courseName = ?',
                whereArgs: [myGrade.year, myGrade.courseName],
              );

              if (result.isNotEmpty) {
                myGrade.id = result.first['id'];
              }
            }
          }
        }
      }
    }
  }

// MiddleClass を取得する関数
  static Future<List<MiddleClass>> _getMiddleClasses(int majorClassId) async {
    final db = await _initDB();
    final List<Map<String, dynamic>> middleClassMaps = await db.query(
      middleClassTable,
      where: 'majorClassId = ?',
      whereArgs: [majorClassId],
    );

    List<MiddleClass> middleClasses = [];

    for (var middleClassMap in middleClassMaps) {
      List<MinorClass> minorClasses =
          await _getMinorClasses(middleClassMap['id']);
      middleClasses.add(MiddleClass(
        id: middleClassMap['id'],
        text: middleClassMap['text'],
        requiredCredit: middleClassMap['requiredCredit'],
        acquiredCredit: middleClassMap['acquiredCredit'],
        countedCredit: middleClassMap['countedCredit'],
        minorClass: minorClasses,
        myGrade: await _getMyGradesFromMiddleClass(middleClassMap['id']),
      ));
    }

    return middleClasses;
  }

// MinorClass を取得する関数
  static Future<List<MinorClass>> _getMinorClasses(int middleClassId) async {
    final db = await _initDB();
    final List<Map<String, dynamic>> minorClassMaps = await db.query(
      minorClassTable,
      where: 'middleClassId = ?',
      whereArgs: [middleClassId],
    );

    List<MinorClass> minorClasses = [];

    for (var minorClassMap in minorClassMaps) {
      minorClasses.add(MinorClass(
        id: minorClassMap['id'],
        text: minorClassMap['text'],
        requiredCredit: minorClassMap['requiredCredit'],
        acquiredCredit: minorClassMap['acquiredCredit'],
        countedCredit: minorClassMap['countedCredit'],
        myGrade: await _getMyGradesFromMinorClass(minorClassMap['id']),
      ));
    }

    return minorClasses;
  }

// MyGrade を取得する関数
  static Future<List<MyGrade>> _getMyGradesFromMinorClass(
      int minorClassId) async {
    final db = await _initDB();
    final List<Map<String, dynamic>> myGradeMaps = await db.query(
      myGradeTable,
      where: 'minorClassId = ?',
      whereArgs: [minorClassId],
    );

    return myGradeMaps.map((myGradeMap) {
      return MyGrade(
        id: myGradeMap['id'],
        courseName: myGradeMap['courseName'],
        year: myGradeMap['year'],
        term: myGradeMap['term'],
        credit: myGradeMap['credit'],
        grade: myGradeMap['grade'],
        gradePoint: myGradeMap['gradePoint'],
      );
    }).toList();
  }

  static Future<List<MyGrade>> _getMyGradesFromMiddleClass(
      int middleClassId) async {
    final db = await _initDB();
    final List<Map<String, dynamic>> myGradeMaps = await db.query(
      myGradeTable,
      where: 'middleClassId = ?',
      whereArgs: [middleClassId],
    );

    return myGradeMaps.map((myGradeMap) {
      return MyGrade(
        id: myGradeMap['id'],
        courseName: myGradeMap['courseName'],
        year: myGradeMap['year'],
        term: myGradeMap['term'],
        credit: myGradeMap['credit'],
        grade: myGradeMap['grade'],
        gradePoint: myGradeMap['gradePoint'],
      );
    }).toList();
  }

// MajorClass を全て取得する関数
  static Future<List<MajorClass>> _getAllMajorClasses() async {
    final db = await _initDB();
    final List<Map<String, dynamic>> majorClassMaps =
        await db.query(majorClassTable);
    List<MajorClass> majorClasses = [];

    for (var majorClassMap in majorClassMaps) {
      List<MiddleClass> middleClasses =
          await _getMiddleClasses(majorClassMap['id']);
      majorClasses.add(MajorClass(
        id: majorClassMap['id'],
        text: majorClassMap['text'],
        requiredCredit: majorClassMap['requiredCredit'],
        acquiredCredit: majorClassMap['acquiredCredit'],
        countedCredit: majorClassMap['countedCredit'],
        middleClass: middleClasses,
      ));
    }

    return majorClasses;
  }

  static Future<MyCredit?> getMyCredit() async {
    Map<String, dynamic> map = json.decode(SharepreferenceHandler()
        .getValue(SharepreferenceKeys.graduationRequireCredit));
    if (map.isNotEmpty) {
      MyCredit myCredit = MyCredit(
          requiredCredit: map["requiredCredit"]!,
          acquiredCredit: map["acquiredCredit"]!,
          countedCredit: map["countedCredit"]!,
          majorClass: await _getAllMajorClasses());
      return myCredit;
    }
    return null;
  }
}

class MajorClass {
  int? id;
  String text;
  List<MiddleClass> middleClass;
  int? requiredCredit;
  int acquiredCredit;
  int countedCredit;

  MajorClass({
    this.id,
    required this.text,
    required this.middleClass,
    required this.requiredCredit,
    required this.acquiredCredit,
    required this.countedCredit,
  });

  Map<String, dynamic> toMap() {
    return {
      "text": text,
      "requiredCredit": requiredCredit,
      "acquiredCredit": acquiredCredit,
      "countedCredit": countedCredit,
      "middleClasses": middleClass.map((e) => e.toMap()).toList(),
    };
  }

  toDisplay() {
    printWrapped(const JsonEncoder.withIndent('  ').convert(toMap()));
  }
}

class MiddleClass {
  int? id;
  String text;
  List<MinorClass> minorClass;
  int? requiredCredit;
  int acquiredCredit;
  int countedCredit;
  List<MyGrade> myGrade;

  MiddleClass({
    this.id,
    required this.text,
    required this.minorClass,
    required this.requiredCredit,
    required this.acquiredCredit,
    required this.countedCredit,
    required this.myGrade,
  });
  Map<String, dynamic> toMap() {
    return {
      "text": text,
      "requiredCredit": requiredCredit,
      "acquiredCredit": acquiredCredit,
      "countedCredit": countedCredit,
      "myGrade": myGrade.map((e) => e.toMap()).toList(),
      "minorClass": minorClass.map((e) => e.toMap()).toList(),
    };
  }
}

class MinorClass {
  int? id;
  String text;
  int? requiredCredit;
  int acquiredCredit;
  int countedCredit;
  List<MyGrade> myGrade;

  MinorClass({
    this.id,
    required this.text,
    required this.myGrade,
    required this.requiredCredit,
    required this.acquiredCredit,
    required this.countedCredit,
  });
  Map<String, dynamic> toMap() {
    return {
      "text": text,
      "requiredCredit": requiredCredit,
      "acquiredCredit": acquiredCredit,
      "countedCredit": countedCredit,
      "myGrade": myGrade.map((e) => e.toMap()).toList(),
    };
  }
}

class MyGrade {
  int? id;
  String courseName;
  String year;
  String term;
  int credit;
  String grade;
  String? gradePoint;

  MyGrade({
    this.id,
    required this.courseName,
    required this.credit,
    required this.grade,
    required this.term,
    required this.year,
    required this.gradePoint,
  });
  Map<String, dynamic> toMap() {
    return {
      "courseName": courseName,
      "year": year,
      "term": term,
      "credit": credit,
      "grade": grade,
      "gradePoint": gradePoint
    };
  }
}

class MyCredit {
  int requiredCredit;
  int acquiredCredit;
  int countedCredit;
  String text = "卒業要件単位数";
  List<MajorClass> majorClass;
  MyCredit(
      {required this.requiredCredit,
      required this.acquiredCredit,
      required this.countedCredit,
      required this.majorClass});
  Map<String, dynamic> toMap() {
    return {
      "text": text,
      "requiredCredit": requiredCredit,
      "acquiredCredit": acquiredCredit,
      "countedCredit": countedCredit,
      "majorClass": majorClass.map((e) => e.toMap()).toList(),
    };
  }

  toDisplay() {
    printWrapped(const JsonEncoder.withIndent('  ').convert(toMap()));
  }
}
