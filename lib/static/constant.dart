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
  final String text;
  final String value;
  final String? shortText;
  final String fullText;
  static List<String> whenTerms(DateTime dateTime) {
    List<String> currentTerms = [];
    List<DateTime> datetimeList = wasedaCalendar2024.values.toList();

    if ((dateTime.isAfter(datetimeList[1]) &&
            dateTime.isBefore(datetimeList[2])) ||
        dateTime.isAtSameMomentAs(datetimeList[2]) ||
        dateTime.isAtSameMomentAs(datetimeList[1])) {
      currentTerms.addAll(["spring_semester", "spring_quarter"]);
    }
    if ((dateTime.isAfter(datetimeList[3]) &&
            dateTime.isBefore(datetimeList[4])) ||
        dateTime.isAtSameMomentAs(datetimeList[3]) ||
        dateTime.isAtSameMomentAs(datetimeList[4])) {
      currentTerms.addAll(["spring_semester", "summer_quarter"]);
    }
    if ((dateTime.isAfter(datetimeList[7]) &&
            dateTime.isBefore(datetimeList[8])) ||
        dateTime.isAtSameMomentAs(datetimeList[7]) ||
        dateTime.isAtSameMomentAs(datetimeList[8])) {
      currentTerms.addAll(["fall_semester", "fall_quarter"]);
    }
    if ((dateTime.isAfter(datetimeList[9]) &&
            dateTime.isBefore(datetimeList[11])) ||
        dateTime.isAtSameMomentAs(datetimeList[9]) ||
        dateTime.isAtSameMomentAs(datetimeList[11])) {
      currentTerms.addAll(["fall_semester", "winter_quarter"]);
    }
    if (currentTerms.isNotEmpty) {
      currentTerms.add("full_year");
    }
    return currentTerms;
  }

  static String? whenQuarter(DateTime dateTime) {
    List<String> currentTerms = whenTerms(dateTime);
    for (var term in Term.terms.keys) {
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
