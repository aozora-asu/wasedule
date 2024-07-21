import 'package:flutter_calandar_app/static/error_exception/exception.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

enum Term {
  springQuarter(
      value: "spring_quarter",
      text: "春クォーター",
      fullText: "春学期 -春クォーター",
      shortText: "春"),
  summerQuarter(
      value: "summer_quarter",
      text: "夏クォーター",
      fullText: "春学期 -夏クォーター",
      shortText: "夏"),
  springSemester(
      value: "spring_semester", text: "春学期", fullText: "", shortText: "春"),
  fallQuarter(
      value: "fall_quarter",
      text: "秋クォーター",
      fullText: "秋学期 -秋クォーター",
      shortText: "秋"),
  winterQuarter(
      value: "winter_quarter",
      text: "冬クォーター",
      fullText: "秋学期 -冬クォーター",
      shortText: "冬"),
  fallSemester(
      value: "fall_semester", text: "秋学期", fullText: "", shortText: "秋"),
  fullYear(value: "full_year", text: "通年", fullText: "通年科目", shortText: null),
  ;

  const Term(
      {required this.value,
      required this.text,
      required this.shortText,
      required this.fullText});
  final String text;
  final String value;
  final String? shortText;
  final String fullText;
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

  static wherePeriod(DateTime dateTime) {
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
