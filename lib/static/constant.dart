import 'package:flutter_calandar_app/static/converter.dart';
import 'package:flutter_calandar_app/static/error_exception/exception.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

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
      text: "春クォーター",
      fullText: "春学期 -春クォーター",
      shortText: "春");
  static Term summerQuarter = const Term._internal(
      value: "summer_quarter",
      text: "夏クォーター",
      fullText: "春学期 -夏クォーター",
      shortText: "夏");
  static Term springSemester = const Term._internal(
      value: "spring_semester", text: "春学期", fullText: "", shortText: "春");
  static Term fallQuarter = const Term._internal(
      value: "fall_quarter",
      text: "秋クォーター",
      fullText: "秋学期 -秋クォーター",
      shortText: "秋");
  static Term winterQuarter = const Term._internal(
      value: "winter_quarter",
      text: "冬クォーター",
      fullText: "秋学期 -冬クォーター",
      shortText: "冬");
  static Term fallSemester = const Term._internal(
      value: "fall_semester", text: "秋学期", fullText: "", shortText: "秋");
  static Term fullYear = const Term._internal(
      value: "full_year", text: "通年", fullText: "通年科目", shortText: null);

  const Term._internal(
      {required this.value,
      required this.text,
      required this.shortText,
      required this.fullText});
  static Map<String, Term> get terms => {
        springQuarter.value: springQuarter,
        summerQuarter.value: summerQuarter,
        springSemester.value: springSemester,
        fallQuarter.value: fallQuarter,
        winterQuarter.value: winterQuarter,
        fallSemester.value: fallSemester,
        fullYear.value: fullYear
      };
  static Map<String, Term> get semesters => {
        springSemester.value: springSemester,
        fallSemester.value: fallSemester,
      };
  static Map<String, Term> get quarters => {
        springQuarter.value: springQuarter,
        summerQuarter.value: summerQuarter,
        fallQuarter.value: fallQuarter,
        winterQuarter.value: winterQuarter,
      };
  final String text;
  final String value;
  final String? shortText;
  final String fullText;
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
    for (var term in Term.quarters.values) {
      if (currentTerms.contains(term)) {
        return term;
      }
    }
    return null;
  }

  static Term? whenSemester(DateTime dateTime) {
    List<Term> currentTerms = whenTerms(dateTime);
    for (var term in Term.semesters.values) {
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

class Class {
  final DateTime start;
  final DateTime end;
  final int period;

  const Class._internal(
      {required this.start, required this.end, required this.period});

  static Class zeroth = Class._internal(
      period: 0,
      start: tz.TZDateTime.from(DateFormat("H:mm").parse("7:00"), tz.local),
      end: tz.TZDateTime.from(DateFormat("H:mm").parse("8:40"), tz.local));
  static Class first = Class._internal(
      period: 1,
      start: tz.TZDateTime.from(DateFormat("H:mm").parse("8:50"), tz.local),
      end: tz.TZDateTime.from(DateFormat("H:mm").parse("10:30"), tz.local));
  static Class second = Class._internal(
      period: 2,
      start: tz.TZDateTime.from(DateFormat("H:mm").parse("10:40"), tz.local),
      end: tz.TZDateTime.from(DateFormat("H:mm").parse("12:20"), tz.local));
  static Class third = Class._internal(
      period: 3,
      start: tz.TZDateTime.from(DateFormat("H:mm").parse("13:10"), tz.local),
      end: tz.TZDateTime.from(DateFormat("H:mm").parse("14:50"), tz.local));
  static Class fourth = Class._internal(
      period: 4,
      start: tz.TZDateTime.from(DateFormat("H:mm").parse("15:05"), tz.local),
      end: tz.TZDateTime.from(DateFormat("H:mm").parse("16:45"), tz.local));
  static Class fifth = Class._internal(
      period: 5,
      start: tz.TZDateTime.from(DateFormat("H:mm").parse("17:00"), tz.local),
      end: tz.TZDateTime.from(DateFormat("H:mm").parse("18:40"), tz.local));
  static Class sixth = Class._internal(
      period: 6,
      start: tz.TZDateTime.from(DateFormat("H:mm").parse("18:55"), tz.local),
      end: tz.TZDateTime.from(DateFormat("H:mm").parse("20:35"), tz.local));
  static Class seventh = Class._internal(
      period: 7,
      start: tz.TZDateTime.from(DateFormat("H:mm").parse("20:45"), tz.local),
      end: tz.TZDateTime.from(DateFormat("H:mm").parse("21:25"), tz.local));
  static List<Class> get periods => [
        zeroth,
        first,
        second,
        third,
        fourth,
        fifth,
        sixth,
        seventh,
      ];

  static whenPeriod(DateTime dateTime) {
    tz.TZDateTime tzDateTime = tz.TZDateTime.from(
        DateFormat("H:mm").parse("${dateTime.hour}:${dateTime.minute}"),
        tz.local);
    for (var key in periods) {
      if ((tzDateTime.isAfter(key.start) && tzDateTime.isBefore(key.end)) ||
          tzDateTime.isAtSameMomentAs(key.start) ||
          tzDateTime.isAtSameMomentAs(key.end)) {
        return key.period;
      }
    }
    return null;
  }
}

enum AttendStatus {
  attend('attend'),
  late('late'),
  absent('absent'),
  ;

  const AttendStatus(this.value);
  final String value;
}

enum NotifyType {
  daily('daily'),
  weekly('weekly'),
  beforeHour('beforeHour'),
  ;

  const NotifyType(this.value);
  final String value;
}
