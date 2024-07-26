import 'package:flutter_calandar_app/static/converter.dart';
import 'package:flutter_calandar_app/static/error_exception/exception.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import "../frontend/assist_files/colors.dart";

final Map<String, DateTime> wasedaCalendar2024 = {
  "春学期開始": DateTime(2024, 4, 1),
  "春学期授業開始": DateTime(2024, 4, 12),
  "春クォーター終了": DateTime(2024, 6, 3),
  "夏クォーター開始": DateTime(2024, 6, 4),
  "春学期授業終了": DateTime(2024, 7, 29),
  "夏季休業": DateTime(2024, 7, 30),
  "秋学期開始": DateTime(2024, 9, 21),
  "秋学期授業開始": DateTime(2024, 10, 4),
  "秋クォーター終了": DateTime(2024, 11, 25),
  "冬クォーター開始": DateTime(2024, 11, 26),
  "冬季休業": DateTime(2024, 12, 24),
  "秋学期授業終了": DateTime(2025, 2, 3),
  "春季休業": DateTime(2025, 2, 4),
};

class Term {
  static Term springQuarter = const Term._internal(
      value: "spring_quarter",
      quarterGroup: ["spring_quarter"],
      text: "春クォーター",
      fullText: "春学期 -春クォーター",
      shortText: "春");
  static Term summerQuarter = const Term._internal(
      value: "summer_quarter",
      quarterGroup: ["summer_quarter"],
      text: "夏クォーター",
      fullText: "春学期 -夏クォーター",
      shortText: "夏");
  static Term springSemester = const Term._internal(
      value: "spring_semester",
      quarterGroup: ["spring_quarter", "summer_quarter"],
      text: "春学期",
      fullText: "",
      shortText: "春");
  static Term fallQuarter = const Term._internal(
      value: "fall_quarter",
      quarterGroup: ["fall_quarter"],
      text: "秋クォーター",
      fullText: "秋学期 -秋クォーター",
      shortText: "秋");
  static Term winterQuarter = const Term._internal(
      value: "winter_quarter",
      quarterGroup: ["winter_quarter"],
      text: "冬クォーター",
      fullText: "秋学期 -冬クォーター",
      shortText: "冬");
  static Term fallSemester = const Term._internal(
      value: "fall_semester",
      quarterGroup: ["fall_quarter", "winter_quaretr"],
      text: "秋学期",
      fullText: "",
      shortText: "秋");
  static Term fullYear = const Term._internal(
      value: "full_year",
      quarterGroup: [
        "spring_quarter",
        "summer_quarter",
        "fall_quarter",
        "winter_quaretr"
      ],
      text: "通年",
      fullText: "通年科目",
      shortText: null);

  const Term._internal(
      {required this.value,
      required this.quarterGroup,
      required this.text,
      required this.shortText,
      required this.fullText});
  static List<Term> get terms => [
        springQuarter,
        summerQuarter,
        springSemester,
        fallQuarter,
        winterQuarter,
        fallSemester,
        fullYear
      ];
  static List<Term> get _semesters => [
        springSemester,
        fallSemester,
      ];
  static List<Term> get _quarters => [
        springQuarter,
        summerQuarter,
        fallQuarter,
        winterQuarter,
      ];
  final String text;
  final String value;
  final String? shortText;
  final String fullText;
  final List<String> quarterGroup;
  static List<Term> whenTerms(DateTime dateTime) {
    List<Term> currentTerms = [];
    List<DateTime> datetimeList = wasedaCalendar2024.values.toList();
    if (isBetween(dateTime, datetimeList[1], datetimeList[2])) {
      currentTerms.addAll([springSemester, springQuarter]);
    } else if (isBetween(dateTime, datetimeList[3], datetimeList[4])) {
      currentTerms.addAll([springSemester, summerQuarter]);
    } else if (isBetween(dateTime, datetimeList[7], datetimeList[8])) {
      currentTerms.addAll([fallSemester, fallQuarter]);
    } else if (isBetween(dateTime, datetimeList[9], datetimeList[11])) {
      currentTerms.addAll([fallSemester, winterQuarter]);
    }

    if (currentTerms.isNotEmpty) {
      currentTerms.add(fullYear);
    }
    return currentTerms;
  }

  static Term? whenQuarter(DateTime dateTime) {
    List<Term> currentTerms = whenTerms(dateTime);
    for (var term in Term._quarters) {
      if (currentTerms.contains(term)) {
        return term;
      }
    }
    return null;
  }

  static Term? whenSemester(DateTime dateTime) {
    List<Term> currentTerms = whenTerms(dateTime);
    for (var term in Term._semesters) {
      if (currentTerms.contains(term)) {
        return term;
      }
    }
    return null;
  }

  static int whenSchoolYear(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month - 4, dateTime.day).year;
  }
}

class Lesson {
  final DateTime start;
  final DateTime end;
  final int period;

  const Lesson._internal({
    required this.start,
    required this.end,
    required this.period,
  });

  static Lesson zeroth = Lesson._internal(
    period: 0,
    start: tz.TZDateTime.from(DateFormat("HH:mm").parse("7:00"), tz.local),
    end: tz.TZDateTime.from(DateFormat("HH:mm").parse("8:40"), tz.local),
  );
  static Lesson first = Lesson._internal(
    period: 1,
    start: tz.TZDateTime.from(DateFormat("HH:mm").parse("8:50"), tz.local),
    end: tz.TZDateTime.from(DateFormat("HH:mm").parse("10:30"), tz.local),
  );
  static Lesson second = Lesson._internal(
    period: 2,
    start: tz.TZDateTime.from(DateFormat("HH:mm").parse("10:40"), tz.local),
    end: tz.TZDateTime.from(DateFormat("HH:mm").parse("12:20"), tz.local),
  );
  static Lesson third = Lesson._internal(
    period: 3,
    start: tz.TZDateTime.from(DateFormat("HH:mm").parse("13:10"), tz.local),
    end: tz.TZDateTime.from(DateFormat("HH:mm").parse("14:50"), tz.local),
  );
  static Lesson fourth = Lesson._internal(
    period: 4,
    start: tz.TZDateTime.from(DateFormat("HH:mm").parse("15:05"), tz.local),
    end: tz.TZDateTime.from(DateFormat("HH:mm").parse("16:45"), tz.local),
  );
  static Lesson fifth = Lesson._internal(
    period: 5,
    start: tz.TZDateTime.from(DateFormat("HH:mm").parse("17:00"), tz.local),
    end: tz.TZDateTime.from(DateFormat("HH:mm").parse("18:40"), tz.local),
  );
  static Lesson sixth = Lesson._internal(
    period: 6,
    start: tz.TZDateTime.from(DateFormat("HH:mm").parse("18:55"), tz.local),
    end: tz.TZDateTime.from(DateFormat("HH:mm").parse("20:35"), tz.local),
  );
  static Lesson seventh = Lesson._internal(
    period: 7,
    start: tz.TZDateTime.from(DateFormat("HH:mm").parse("20:45"), tz.local),
    end: tz.TZDateTime.from(DateFormat("HH:mm").parse("21:25"), tz.local),
  );
  static List<Lesson> get _periods => [
        zeroth,
        first,
        second,
        third,
        fourth,
        fifth,
        sixth,
        seventh,
      ];

  static Lesson? whenPeriod(DateTime dateTime) {
    tz.TZDateTime tzDateTime = tz.TZDateTime.from(
        DateFormat("HH:mm").parse("${dateTime.hour}:${dateTime.minute}"),
        tz.local);
    for (var lesson in _periods) {
      if (isBetween(tzDateTime, lesson.start, lesson.end)) {
        return lesson;
      } else {
        continue;
      }
    }
    return null;
  }

  static Lesson? atPeriod(int period) {
    if (period < _periods.length) {
      return _periods[period];
    } else {
      return null;
    }
  }
}

class AttendStatus {
  static AttendStatus attend = const AttendStatus._internal(
      value: "attend", text: "出席", color: Colors.blue);
  static AttendStatus late = const AttendStatus._internal(
      value: "late", text: "遅刻", color: Color.fromARGB(255, 223, 200, 0));
  static AttendStatus absent = const AttendStatus._internal(
      value: "absent", text: "欠席", color: Colors.redAccent);
  static Map<String, AttendStatus> get values =>
      {attend.value: attend, late.value: late, absent.value: absent};
  const AttendStatus._internal(
      {required this.value, required this.text, required this.color});
  final String value;
  final String text;
  final Color color;
}

enum NotifyType {
  daily('daily'),
  weekly('weekly'),
  beforeHour('beforeHour'),
  ;

  const NotifyType(this.value);
  final String value;
}

class Department {
  static Department education = const Department._internal(
      value: "education",
      text: "教育学部",
      TLC: "",
      color: Colors.blue,
      departmentID: "151949",
      subjectClassifications: null);
  static Department politicalEconomy = const Department._internal(
      value: "politicalEconomy",
      text: "政治経済学部",
      TLC: "PSE",
      color: WASEDA_PSE_COLOR,
      departmentID: "111973",
      subjectClassifications: null);
  static Department law = const Department._internal(
      value: "law",
      text: "法学部",
      TLC: "LAW",
      color: WASEDA_LAW_COLOR,
      departmentID: "121973",
      subjectClassifications: null);
  static Department commerce = const Department._internal(
      value: "commerce",
      text: "商学部",
      TLC: "SOC",
      color: WASEDA_SOC_COLOR,
      departmentID: "161973",
      subjectClassifications: null);
  static Department internationalEducation = const Department._internal(
      value: "internationalEducation",
      text: "国際教養悪部",
      TLC: "SILS",
      color: WASEDA_SILS_COLOR,
      departmentID: "212004",
      subjectClassifications: null);
  static Department socialScience = const Department._internal(
      value: "socialScience",
      text: "社会科学部",
      TLC: "SSS",
      color: WASEDA_SSS_COLOR,
      departmentID: "181966",
      subjectClassifications: null);

  static Department literature = const Department._internal(
      value: "literature",
      text: "文学部",
      TLC: "HSS",
      color: WASEDA_HSS_COLOR,
      departmentID: "242006",
      subjectClassifications: null);
  static Department cultureAndMediaStudie = const Department._internal(
      value: "cultureAndMediaStudie",
      text: "文化構想学部",
      TLC: "CMS",
      color: WASEDA_CMS_COLOR,
      departmentID: "232006",
      subjectClassifications: null);
  static Department advancedScience = const Department._internal(
      value: "advancedScience",
      text: "先進理工学部",
      TLC: "ASE",
      color: WASEDA_ASE_COLOR,
      departmentID: "282006",
      subjectClassifications: null);
  static Department creativeScience = const Department._internal(
      value: "creativeScience",
      text: "創造理工学部",
      TLC: "CSE",
      color: WASEDA_CSE_COLOR,
      departmentID: "272006",
      subjectClassifications: null);
  static Department fundamentalScience = const Department._internal(
      value: "fundamentalScience",
      text: "基幹理工学部",
      TLC: "FSE",
      color: WASEDA_FSE_COLOR,
      departmentID: "262006",
      subjectClassifications: null);
  static Department humanScience = const Department._internal(
      value: "humanScience",
      text: "人間科学部",
      TLC: "HUM",
      color: WASEDA_HUM_COLOR,
      departmentID: "192000",
      subjectClassifications: null);
  static Department sportsScience = const Department._internal(
      value: "sportsScience",
      text: "スポーツ科学部",
      TLC: "SPS",
      color: WASEDA_SPS_COLOR,
      departmentID: "202003",
      subjectClassifications: null);
  static Department global = const Department._internal(
      value: "global",
      text: "グローバル",
      TLC: "",
      color: MAIN_COLOR,
      departmentID: "9S2013",
      subjectClassifications: null);

  const Department._internal(
      {required this.value,
      required this.text,
      required this.departmentID,
      required this.TLC,
      required this.color,
      required this.subjectClassifications});
  final String value;
  final String text;
  final String departmentID;
  final String TLC;
  final Color color;
  final List<__SubjectClassification>? subjectClassifications;

  static Map<String, Department> get departments => {};
}

class __SubjectClassification {
  final String parentDepartment;
  final String p_keya;
  final String text;
  const __SubjectClassification._internal(
      {required this.p_keya,
      required this.parentDepartment,
      required this.text});

  static const List<__SubjectClassification> advancedSubClass = [
    __SubjectClassification._internal(
        p_keya: "2801001",
        parentDepartment: "advancedScience",
        text: "物理学科(専門科目)"),
    __SubjectClassification._internal(
        p_keya: "2801002",
        parentDepartment: "advancedScience",
        text: "応用物理学科(専門科目)"),
    __SubjectClassification._internal(
        p_keya: "2801003",
        parentDepartment: "advancedScience",
        text: "化学･生命科学科(専門科目)"),
    __SubjectClassification._internal(
        p_keya: "2801004",
        parentDepartment: "advancedScience",
        text: "応用科学科(専門科目)"),
    __SubjectClassification._internal(
        p_keya: "2801005",
        parentDepartment: "advancedScience",
        text: "生命医科学科(専門科目)"),
    __SubjectClassification._internal(
        p_keya: "2801006",
        parentDepartment: "advancedScience",
        text: "電気･情報生命工学科(専門科目)"),
    __SubjectClassification._internal(
        p_keya: "2801010",
        parentDepartment: "advancedScience",
        text: "A群:複合領域"),
    __SubjectClassification._internal(
        p_keya: "2801012",
        parentDepartment: "advancedScience",
        text: "A群:外国語-英語"),
    __SubjectClassification._internal(
        p_keya: "2801013",
        parentDepartment: "advancedScience",
        text: "A群:外国語-初修外国語"),
    __SubjectClassification._internal(
        p_keya: "2801014", parentDepartment: "advancedScience", text: "B群:数学"),
    __SubjectClassification._internal(
        p_keya: "2801015",
        parentDepartment: "advancedScience",
        text: "B群:自然科学"),
    __SubjectClassification._internal(
        p_keya: "2801016",
        parentDepartment: "advancedScience",
        text: "B群:実験･実習･制作"),
    __SubjectClassification._internal(
        p_keya: "2801017",
        parentDepartment: "advancedScience",
        text: "B群:情報関連科目"),
  ];
  static const List<__SubjectClassification> creativeSubClass = [
    __SubjectClassification._internal(
        p_keya: "2701001",
        parentDepartment: "creativeScience",
        text: "建築学科(専門科目)"),
    __SubjectClassification._internal(
        p_keya: "2701002",
        parentDepartment: "creativeScience",
        text: "総合機械工学科(専門科目)"),
    __SubjectClassification._internal(
        p_keya: "2701003",
        parentDepartment: "creativeScience",
        text: "経営システム工学科(専門科目)"),
    __SubjectClassification._internal(
        p_keya: "2701004",
        parentDepartment: "creativeScience",
        text: "社会環境工学科(専門科目)"),
    __SubjectClassification._internal(
        p_keya: "2701005",
        parentDepartment: "creativeScience",
        text: "環境資源工学科(専門科目)"),
    __SubjectClassification._internal(
        p_keya: "2701009",
        parentDepartment: "creativeScience",
        text: "C群:創造理工学部共通科目"),
    __SubjectClassification._internal(
        p_keya: "2701010",
        parentDepartment: "creativeScience",
        text: "A群:複合領域"),
    __SubjectClassification._internal(
        p_keya: "2701012",
        parentDepartment: "creativeScience",
        text: "A群:外国語-英語"),
    __SubjectClassification._internal(
        p_keya: "2701013",
        parentDepartment: "creativeScience",
        text: "A群:外国語-初修外国語"),
    __SubjectClassification._internal(
        p_keya: "2701014", parentDepartment: "creativeScience", text: "B群:数学"),
    __SubjectClassification._internal(
        p_keya: "2701015",
        parentDepartment: "creativeScience",
        text: "B群:自然科学"),
    __SubjectClassification._internal(
        p_keya: "2701016",
        parentDepartment: "creativeScience",
        text: "B群:実験･実習･制作"),
    __SubjectClassification._internal(
        p_keya: "2701017",
        parentDepartment: "creativeScience",
        text: "B群:情報関連科目"),
  ];
  static const List<__SubjectClassification> fundamentalSubClass = [
    __SubjectClassification._internal(
        p_keya: "2601002",
        parentDepartment: "fundamentalScience",
        text: "数学科(専門科目)"),
    __SubjectClassification._internal(
        p_keya: "2601003",
        parentDepartment: "fundamentalScience",
        text: "応用数理学科(専門科目)"),
    __SubjectClassification._internal(
        p_keya: "2601004",
        parentDepartment: "fundamentalScience",
        text: "情報理工学科(専門科目)"),
    __SubjectClassification._internal(
        p_keya: "2601005",
        parentDepartment: "fundamentalScience",
        text: "機械科学･航空学科(専門科目)"),
    __SubjectClassification._internal(
        p_keya: "2601006",
        parentDepartment: "fundamentalScience",
        text: "電子物理システム学科(専門科目)"),
    __SubjectClassification._internal(
        p_keya: "2601007",
        parentDepartment: "fundamentalScience",
        text: "表現工学科(専門科目)"),
    __SubjectClassification._internal(
        p_keya: "2601008",
        parentDepartment: "fundamentalScience",
        text: "表現工学科(専門科目)"),
    __SubjectClassification._internal(
        p_keya: "2601009",
        parentDepartment: "fundamentalScience",
        text: "情報通信学科(専門科目)"),
    __SubjectClassification._internal(
        p_keya: "2601010",
        parentDepartment: "fundamentalScience",
        text: "A群:複合領域"),
    __SubjectClassification._internal(
        p_keya: "2601012",
        parentDepartment: "fundamentalScience",
        text: "A群:外国語-英語"),
    __SubjectClassification._internal(
        p_keya: "2601013",
        parentDepartment: "fundamentalScience",
        text: "A群:外国語-初修外国語"),
    __SubjectClassification._internal(
        p_keya: "2601014",
        parentDepartment: "fundamentalScience",
        text: "B群:数学"),
    __SubjectClassification._internal(
        p_keya: "2601015",
        parentDepartment: "fundamentalScience",
        text: "B群:自然科学"),
    __SubjectClassification._internal(
        p_keya: "2601016",
        parentDepartment: "fundamentalScience",
        text: "B群:実験･実習･制作"),
    __SubjectClassification._internal(
        p_keya: "2601017",
        parentDepartment: "fundamentalScience",
        text: "B群:情報関連科目"),
  ];
}
