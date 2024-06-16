import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';

import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

String? period2startTime(int period) {
  switch (period) {
    case 1:
      return "8:50";
    case 2:
      return "10:40";
    case 3:
      return "13:10";
    case 4:
      return "15:05";
    case 5:
      return "17:00";
    case 6:
      return "18:55";
    case 7:
      return "20:45";
    default:
      return null;
  }
}

String? period2endTime(int period) {
  switch (period) {
    case 1:
      return "10:30";
    case 2:
      return "12:20";
    case 3:
      return "14:50";
    case 4:
      return "16:50";
    case 5:
      return "18:40";
    case 6:
      return "20:35";
    case 7:
      return "21:35";
    default:
      return null;
  }
}

String? period2duringTime(int period) {
  switch (period) {
    case 1:
      return "8:50~10:30";
    case 2:
      return "10:40~12:20";
    case 3:
      return "13:10~14:50";
    case 4:
      return "15:05~16:45";
    case 5:
      return "17:00~18:40";
    case 6:
      return "18:55~20:35";
    case 7:
      return "20:45~21:35";
    default:
      return null;
  }
}

int? datetime2Period(DateTime datetime) {
  // 各periodの開始時間を定義
  List<DateTime> periodStartTimes = [
    DateTime(datetime.year, datetime.month, datetime.day, 8, 50), // period 1
    DateTime(datetime.year, datetime.month, datetime.day, 10, 40), // period 2
    DateTime(datetime.year, datetime.month, datetime.day, 13, 10), // period 3
    DateTime(datetime.year, datetime.month, datetime.day, 15, 5), // period 4
    DateTime(datetime.year, datetime.month, datetime.day, 17, 0), // period 5
  ];

  // datetimeがどのperiodに属するかを判定
  for (int i = 0; i < periodStartTimes.length; i++) {
    DateTime startTime = periodStartTimes[i];
    DateTime endTime = startTime
        .add(const Duration(hours: 1, minutes: 40)); // 各periodは1時間40分間隔

    if (datetime.isAfter(startTime) && datetime.isBefore(endTime)) {
      return i + 1; // periodは1から始まるため、インデックスに1を加える
    }
  }

  return null; // periodに該当しない場合はnullを返す
}

int datetime2schoolYear(DateTime datetime) {
  return DateTime(datetime.year, datetime.month - 4, datetime.day).year;
}

String? weekday2string(int? weekday, String format) {
  if (weekday != null) {
    switch (format) {
      case "E":
        return "月火水木金"[weekday];
      case "EEE":
        return "${"月火水木金"[weekday]}曜日";
      case "(E)":
        return "(${"月火水木金"[weekday]})";
      default:
        return "月火水木金"[weekday];
    }
  } else {
    return null;
  }
}

// Color型からint型への変換関数
int color2int(Color? color) {
  color ??= MAIN_COLOR;
  // 16進数の赤、緑、青、アルファの値を結合して1つの整数に変換する
  return (color.alpha << 24) |
      (color.red << 16) |
      (color.green << 8) |
      color.blue;
}

String zenkaku2hankaku(String fullWidthString) {
  const fullWidthChars =
      '０１２３４５６７８９ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ！＃＄％＆’（）＊＋，－．／：；＜＝＞？＠［￥］＾＿‘｛｜｝～';
  const halfWidthChars =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!#\$%&\'()*+,-./:;<=>?@[¥]^_`{|}~';
  final map = Map.fromIterables(fullWidthChars.runes, halfWidthChars.runes);

  final result = fullWidthString.runes.map((charCode) {
    return map[charCode] != null
        ? String.fromCharCode(map[charCode]!)
        : String.fromCharCode(charCode);
  }).join('');

  return result;
}

int? weekdayToNumber(String? weekday) {
  switch (weekday) {
    case '月':
      return 1;
    case '火':
      return 2;
    case '水':
      return 3;
    case '木':
      return 4;
    case '金':
      return 5;
    case '土':
      return 6;
    case '日':
      return 7;
    case null:
      return null;
    default:
      return null; // 不明な曜日の場合
  }
}

List<String> datetime2termList(DateTime datetime) {
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

  List<String> currentTerms = [];
  List<DateTime> datetimeList = wasedaCalendar2024.values.toList();

  if ((datetime.isAfter(datetimeList[1]) &&
          datetime.isBefore(datetimeList[2])) ||
      datetime.isAtSameMomentAs(datetimeList[2]) ||
      datetime.isAtSameMomentAs(datetimeList[1])) {
    currentTerms.addAll(["spring_semester", "spring_quarter"]);
  }
  if ((datetime.isAfter(datetimeList[3]) &&
          datetime.isBefore(datetimeList[4])) ||
      datetime.isAtSameMomentAs(datetimeList[3]) ||
      datetime.isAtSameMomentAs(datetimeList[4])) {
    currentTerms.addAll(["spring_semester", "summer_quarter"]);
  }
  if ((datetime.isAfter(datetimeList[7]) &&
          datetime.isBefore(datetimeList[8])) ||
      datetime.isAtSameMomentAs(datetimeList[7]) ||
      datetime.isAtSameMomentAs(datetimeList[8])) {
    currentTerms.addAll(["fall_semester", "fall_quarter"]);
  }
  if ((datetime.isAfter(datetimeList[9]) &&
          datetime.isBefore(datetimeList[11])) ||
      datetime.isAtSameMomentAs(datetimeList[9]) ||
      datetime.isAtSameMomentAs(datetimeList[11])) {
    currentTerms.addAll(["fall_semester", "winter_quarter"]);
  }
  if (currentTerms.isNotEmpty) {
    currentTerms.add("full_year");
  }
  return currentTerms;
}

String? datetime2quarter(DateTime datetime) {
  List<String> currentTermList = datetime2termList(datetime);
  if (currentTermList.contains("spring_quarter")) {
    return "spring_quarter";
  } else if (currentTermList.contains("summer_quarter")) {
    return "summer_quarter";
  } else if (currentTermList.contains("fall_quarter")) {
    return "fall_quarter";
  } else if (currentTermList.contains("winter_quarter")) {
    return "winter_quarter";
  } else {
    return null;
  }
}

List<String> semester2quarterList(String text) {
  switch (text) {
    case "spring_quarter":
      return ["spring_quarter"];
    case "summer_quarter":
      return ["summer_quarter"];
    case "spring_semester":
      return ["spring_quarter", "summer_quarter"];
    case "fall_quarter":
      return ["fall_quarter"];
    case "winter_quarter":
      return ["winter_quarter"];
    case "fall_semester":
      return ["fall_quarter", "winter_quarter"];
    case "full_year":
      return [
        "spring_quarter",
        "summer_quarter",
        "fall_quarter",
        "winter_quarter"
      ];

    default:
      return [];
  }
}

String? convertSemester(String? text) {
  switch (text) {
    case "春クォーター":
      return "spring_quarter";
    case "夏クォーター":
      return "summer_quarter";
    case "春学期":
      return "spring_semester";
    case "秋クォーター":
      return "fall_quarter";
    case "冬クォーター":
      return "winter_quarter";
    case "秋学期":
      return "fall_semester";
    case "通年":
      return "full_year";
    default:
      return null;
  }
}

//これはuiで見た目を変える用
String HHmm2Hmm(String HHmmString) {
  // HH:mm 形式の文字列を DateTime オブジェクトに変換
  DateTime dateTime = DateFormat('HH:mm').parse(HHmmString);

  // H:mm 形式にフォーマットして文字列に変換
  return DateFormat('H:mm').format(dateTime);
}

//こっちはdbに入れる時に
String Hmm2HHmm(String HmmString) {
  // H:mm 形式の文字列を DateTime オブジェクトに変換
  DateTime dateTime = DateFormat('H:mm').parse(HmmString);

  // HH:mm 形式にフォーマットして文字列に変換
  return DateFormat('HH:mm').format(dateTime);
}
