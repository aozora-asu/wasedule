import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';
import "error_exception/error.dart";
import 'package:timezone/timezone.dart' as tz;

enum Term {
  springQuarter(value: "spring_quarter", jp: "春クォーター", short: "春"),
  summerQuarter(value: "summer_quarter", jp: "夏クォーター", short: "夏"),
  springSemester(value: "spring_semester", jp: "春学期", short: "春"),
  fallQuarter(value: "fall_quarter", jp: "秋クォーター", short: "秋"),
  winterQuarter(value: "winter_quarter", jp: "冬クォーター", short: "冬"),
  fallSemester(value: "fall_semester", jp: "秋学期", short: "秋"),
  fullYear(value: "full_year", jp: "通年", short: null),
  ;

  const Term({required this.value, required this.jp, required this.short});
  final String jp;
  final String value;
  final String? short;
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
  static List<Class> get keys => [
        zeroth,
        first,
        second,
        third,
        fourth,
        fifth,
        sixth,
        seventh,
      ];
  static time(int period) {
    try {
      return keys[period];
    } catch (e) {
      const ServerCommonError(ServerCommonErrorCode.forbiddenError);
    }
  }

  static wherePeriod(DateTime dateTime) {
    TZDateTime tzDateTime = tz.TZDateTime.from(
        DateFormat("H:mm").parse("${dateTime.hour}:${dateTime.minute}"),
        tz.local);
    for (var key in keys) {
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
