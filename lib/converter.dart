import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';

import 'dart:ui';

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
  return DateTime(datetime.year, datetime.month - 3, datetime.day).year;
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
        return null;
    }
  } else {
    return null;
  }
}

// Color型からint型への変換関数
int color2int(Color? color) {
  if (color == null) {
    color = MAIN_COLOR;
  }
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

// String now2term() {
//   DateTime now = DateTime.now();
//   switch (now.month) {
//     case 1:
//       return "spring_semester";
//   }
// }