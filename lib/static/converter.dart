import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';

import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import "constant.dart";

bool isBetween(DateTime dateTime, DateTime startTime, DateTime endTime) {
  return (dateTime.isAfter(startTime) && dateTime.isBefore(endTime)) ||
      dateTime.isAtSameMomentAs(startTime) ||
      dateTime.isAtSameMomentAs(endTime);
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
      '０１２３４５６７８９ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ！＃＄％＆’（）＊＋，－．／：；＜＝＞？＠［￥］＾＿‘｛｜｝～　';
  const halfWidthChars =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!#\$%&\'()*+,-./:;<=>?@[¥]^_`{|}~ ';
  final map = Map.fromIterables(fullWidthChars.runes, halfWidthChars.runes);

  final result = fullWidthString.runes.map((charCode) {
    return map[charCode] != null
        ? String.fromCharCode(map[charCode]!)
        : String.fromCharCode(charCode);
  }).join('');

  return result;
}
