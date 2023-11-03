import 'package:flutter/material.dart';
import "../../../colors.dart";

Widget appBar() {
  return AppBar(
    backgroundColor: MAIN_COLOR,
    title: Center(
      child: const Column(children: <Widget>[
        Text(
          'わせジュール',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          '早稲田生のためのスケジュールアプリ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ]),
    ),
  );
}
