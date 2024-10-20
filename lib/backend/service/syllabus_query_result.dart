import 'package:flutter_calandar_app/backend/DB/isar_collection/isar_handler.dart';
import 'package:flutter_calandar_app/backend/DB/isar_collection/vacant_room.dart';
import 'package:flutter_calandar_app/static/constant.dart';
import 'package:flutter_calandar_app/static/converter.dart';

import "classRoom.dart";

import "../DB/handler/my_course_db.dart";
import "syllabus_query_request.dart";

class SyllabusQueryResult {
  final String courseName;
  final String classRoom;
  final String semesterAndWeekdayAndPeriod;
  final int year;
  final String? syllabusID;

  final String? teacher;
  final String? criteria;
  final String? subjectClassification;
  final int? credit;
  final String? department;

  final String? remark;
  final String? reference;
  final String? textbook;
  final String? agenda;
  final String? abstract;
  final String? campus;
  final String? lectureSystem;
  final String? allocatedYear;

  SyllabusQueryResult(
      {required this.courseName,
      required this.classRoom,
      required this.year,
      required this.syllabusID,
      required this.semesterAndWeekdayAndPeriod,
      required this.teacher,
      required this.credit,
      required this.criteria,
      required this.department,
      required this.subjectClassification,
      required this.abstract,
      required this.agenda,
      required this.reference,
      required this.remark,
      required this.textbook,
      required this.allocatedYear,
      required this.campus,
      required this.lectureSystem});
  Map<String, dynamic> toMap() {
    return {
      "courseName": courseName,
      "classRoom": classRoom,
      "year": year,
      "syllabusID": syllabusID,
      "teacher": teacher,
      "criteria": criteria,
      "subjectClassification": subjectClassification,
      "credit": credit,
      "department": department
    };
  }

  String _extractClassRoom(String input) {
    RegExp pattern3 = RegExp(r'\d+:(.*)\s');
    Iterable<RegExpMatch> matches = pattern3.allMatches(input);
    if (matches.isEmpty) {
      return input;
    } else {
      return matches.map((e) => e.group(1)).toList().join("\n").trimRight();
    }
  }

  Future<void> resisterMyCourseDB() async {
    List<Map<String, dynamic>> semesterAndWeekdayAndPerid =
        extractDayAndPeriod(semesterAndWeekdayAndPeriod);
    MyCourse myCourse;
    for (var time in semesterAndWeekdayAndPerid) {
      myCourse = MyCourse(
          attendCount: null,
          classRoom: classRoom,
          color: "#F6BFBC",
          courseName: courseName,
          memo: null,
          pageID: syllabusID,
          period:
              time["period"] != null ? Lesson.atPeriod(time["period"]) : null,
          semester: Term.byText(semesterAndWeekdayAndPeriod),
          syllabusID: syllabusID,
          weekday: time["weekday"] != null
              ? DayOfWeek.weekAt(time["weekday"])
              : null,
          year: year,
          criteria: criteria,
          remainAbsent: null,
          classNum: null,
          subjectClassification: subjectClassification,
          credit: credit);
      myCourse.resisterDB();
    }
  }
}

List<Map<String, int?>> extractDayAndPeriod(String input) {
  // 「月3時限」タイプの抽出
  RegExp pattern1 = RegExp(r'([月火水木金土日])(\d)時限');
  // 「月3-4」タイプの抽出
  RegExp pattern2 = RegExp(r'([月火水木金土日])(\d)-(\d)');

  RegExp pattern3 = RegExp(r'無その他');
  int? weekday;
  List<Map<String, int?>> result = [];
  if (pattern2.hasMatch(input)) {
    Iterable<RegExpMatch> matches = pattern2.allMatches(input);

    for (var match in matches) {
      if ("日月火水木金土".contains(match.group(1)!)) {
        weekday = "日月火水木金土".indexOf(match.group(1)!);
      } else {
        weekday = null;
      }
      for (int i = int.parse(match.group(2)!);
          i <= int.parse(match.group(3)!);
          i++) {
        result.add({'weekday': weekday, 'period': i});
      }
    }
  }

  if (pattern1.hasMatch(input)) {
    Iterable<RegExpMatch> matches = pattern1.allMatches(input);
    for (var match in matches) {
      if ("日月火水木金土".contains(match.group(1)!)) {
        weekday = "日月火水木金土".indexOf(match.group(1)!);
      } else {
        weekday = null;
      }
      result.add({'weekday': weekday, 'period': int.tryParse(match.group(2)!)});
    }
  }
  if (pattern3.hasMatch(input)) {
    result.add({'weekday': null, 'period': null});
  }
  if (result.isEmpty) {
    result.add({'weekday': null, 'period': null});
  }

  return result;
}

Future<void> resisterVacantRoomList(String buildingNum) async {
  List<String> classRoomList = classMap[buildingNum] ?? [];
  Map<String, Map<String, Map<String, List<String>>>> copyQuarterClassRoomList;
  SyllabusRequestQuery syllabusrequestQuery;
  List<Map<String, int?>> periodAndDateList;

  List<String> quarterList = [];
  Term? semester;
  copyQuarterClassRoomList =
      _createQuarterClassRoomMap(buildingNum: buildingNum);
  for (var classRoom in classRoomList) {
    syllabusrequestQuery = SyllabusRequestQuery(
      keyword: classRoom,
      kamoku: null,
      p_gakki: null,
      p_youbi: null,
      p_jigen: null,
      p_gengo: null,
      p_gakubu: null,
      p_open: false,
      subjectClassification: null,
      p_number: "100",
    );

    final trElements = await syllabusrequestQuery.fetchSyllabusSearchResults();
    if (trElements.isNotEmpty) {
      trElements.removeAt(0);
      int weekday;
      int period;

      for (var trElement in trElements) {
        final tdElements = trElement.querySelectorAll("td");
        periodAndDateList =
            extractDayAndPeriod(zenkaku2hankaku(tdElements[6].text));
        semester = Term.byText(tdElements[5].text);

        if (semester != null) {
          quarterList = semester.quarterGroup;

          //クォーター制に分割して、合致するところにデータを挿入する
          for (var quarter in quarterList) {
            //時限-曜日が複数羅列している時の処理
            for (var periodAndDate in periodAndDateList) {
              if (periodAndDate["weekday"] != null &&
                  periodAndDate["period"] != null) {
                weekday = periodAndDate["weekday"]!;
                period = periodAndDate["period"]!;

                IsarHandler().resisterClassRoom(
                    isar!,
                    Building(buildingName: buildingNum),
                    ClassRoom(classRoomName: classRoom),
                    HasClass(
                        weekday: weekday, period: period, quarter: quarter));
              }
            }
          }
          //await Future.delayed(const Duration(milliseconds: 500));
        } else {
          continue;
        }
      }
    } else {
      continue;
    }
  }
}

Map<String, Map<String, Map<String, List<String>>>> _createQuarterClassRoomMap(
    {required String buildingNum}) {
  Map<String, Map<String, Map<String, List<String>>>> quarterClassRoomMap = {};

  // Iterate over quarters
  for (String quarter in [
    Term.springQuarter.value,
    Term.summerQuarter.value,
    Term.fallQuarter.value,
    Term.winterQuarter.value
  ]) {
    quarterClassRoomMap.putIfAbsent(quarter, () => {});

    // Iterate over days (Monday to Friday)
    for (int day = 1; day <= 5; day++) {
      quarterClassRoomMap[quarter]!.putIfAbsent(day.toString(), () => {});

      // Iterate over periods (1st to 6rd)
      for (int period = 1; period <= 6; period++) {
        quarterClassRoomMap[quarter]![day.toString()]!
            .putIfAbsent(period.toString(), () => []);

        // Insert classRoomList based on buildingNum
        List<String> classRoomList = classMap[buildingNum] ?? [];
        quarterClassRoomMap[quarter]![day.toString()]![period.toString()]!
            .addAll(classRoomList);
      }
    }
  }
  return quarterClassRoomMap;
}

Future<List<MyCourse>?> getMyCourse(MoodleCourse moodleCourse) async {
  List<MyCourse>? myCourseList = [];

  SyllabusRequestQuery syllabusrequestQuery = SyllabusRequestQuery(
    keyword: moodleCourse.department,
    kamoku: moodleCourse.courseName.replaceAll("・", " "),
    p_gakki: null,
    p_youbi: null,
    p_jigen: null,
    p_gengo: null,
    p_gakubu: null,
    p_open: false,
    subjectClassification: null,
  );

  SyllabusQueryResult? syllabusQueryResult;

  if (moodleCourse.courseName == "確率・統計") {
    syllabusQueryResult = await syllabusrequestQuery
        .getFirstSingleSyllabusInfo(moodleCourse.courseName);
  } else {
    syllabusQueryResult =
        await syllabusrequestQuery.getFirstSingleSyllabusInfo(null);
  }

  if (syllabusQueryResult != null) {
    List<Map<String, dynamic>> semesterAndWeekdayAndPerid =
        extractDayAndPeriod(syllabusQueryResult.semesterAndWeekdayAndPeriod);
    for (var time in semesterAndWeekdayAndPerid) {
      MyCourse myCourse = MyCourse(
          attendCount: null,
          classNum: null,
          memo: null,
          remainAbsent: null,
          classRoom: syllabusQueryResult.classRoom,
          color: moodleCourse.color,
          courseName: moodleCourse.courseName,
          pageID: moodleCourse.pageID,
          period:
              time["period"] != null ? Lesson.atPeriod(time["period"]) : null,
          semester:
              Term.byText(syllabusQueryResult.semesterAndWeekdayAndPeriod),
          syllabusID: syllabusQueryResult.syllabusID,
          weekday: time["weekday"] != null
              ? DayOfWeek.weekAt(time["weekday"])
              : null,
          year: syllabusQueryResult.year,
          criteria: syllabusQueryResult.criteria,
          subjectClassification: syllabusQueryResult.subjectClassification,
          credit: syllabusQueryResult.credit);
      myCourseList.add(myCourse);
    }
  }

  return myCourseList;
}
