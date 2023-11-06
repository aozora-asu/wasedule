import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/colors.dart';

Widget floatButton(func) {
  return FloatingActionButton(
    onPressed: () {
      func();
    },
    backgroundColor: MAIN_COLOR, // ボタンの背景色
    child: const Icon(Icons.get_app), // ボタンのアイコン
  );
}
