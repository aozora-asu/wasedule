import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

enum Terms {
  springQuarter(en: "spring_quarter", jp: "春クォーター"),
  summerQuarter(en: "summer_quarter", jp: "夏クォーター"),
  springSemester(en: "spring_semester", jp: "春学期"),
  fallQuarter(en: "fall_quarter", jp: "秋クォーター"),
  winterQuarter(en: "winter_quarter", jp: "冬クォーター"),
  fallSemester(en: "fall_semester", jp: "秋学期"),
  fullYear(en: "full_year", jp: "通年"),
  ;

  const Terms({required this.en, required this.jp});
  final String jp;
  final String en;
}

enum Semesters {
  springSemester(en: "spring_semester", jp: "春学期"),
  fallSemester(en: "fall_semester", jp: "秋学期"),
  ;

  const Semesters({required this.en, required this.jp});
  final String jp;
  final String en;
}

enum Quarters {
  springQuarter(en: "spring_quarter", jp: "春クォーター"),
  summerQuarter(en: "summer_quarter", jp: "夏クォーター"),
  fallQuarter(en: "fall_quarter", jp: "秋クォーター"),
  winterQuarter(en: "winter_quarter", jp: "冬クォーター"),
  ;

  const Quarters({required this.en, required this.jp});
  final String jp;
  final String en;
}

class ClassTime {
  final DateTime start;
  final DateTime end;
  const ClassTime._internal({required this.start, required this.end});

  static ClassTime zeroth = ClassTime._internal(
      start: tz.TZDateTime.from(DateFormat("H:mm").parse("7:00"), tz.local),
      end: tz.TZDateTime.from(DateFormat("H:mm").parse("8:40"), tz.local));
  static ClassTime first = ClassTime._internal(
      start: tz.TZDateTime.from(DateFormat("H:mm").parse("8:50"), tz.local),
      end: tz.TZDateTime.from(DateFormat("H:mm").parse("10:30"), tz.local));
  static ClassTime second = ClassTime._internal(
      start: tz.TZDateTime.from(DateFormat("H:mm").parse("10:40"), tz.local),
      end: tz.TZDateTime.from(DateFormat("H:mm").parse("12:20"), tz.local));
  static ClassTime third = ClassTime._internal(
      start: tz.TZDateTime.from(DateFormat("H:mm").parse("13:10"), tz.local),
      end: tz.TZDateTime.from(DateFormat("H:mm").parse("14:50"), tz.local));
  static ClassTime fourth = ClassTime._internal(
      start: tz.TZDateTime.from(DateFormat("H:mm").parse("15:05"), tz.local),
      end: tz.TZDateTime.from(DateFormat("H:mm").parse("16:45"), tz.local));
  static ClassTime fifth = ClassTime._internal(
      start: tz.TZDateTime.from(DateFormat("H:mm").parse("17:00"), tz.local),
      end: tz.TZDateTime.from(DateFormat("H:mm").parse("18:40"), tz.local));
  static ClassTime sixth = ClassTime._internal(
      start: tz.TZDateTime.from(DateFormat("H:mm").parse("18:55"), tz.local),
      end: tz.TZDateTime.from(DateFormat("H:mm").parse("20:35"), tz.local));
  static ClassTime seventh = ClassTime._internal(
      start: tz.TZDateTime.from(DateFormat("H:mm").parse("20:45"), tz.local),
      end: tz.TZDateTime.from(DateFormat("H:mm").parse("21:25"), tz.local));
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
