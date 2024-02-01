import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';

Future<Widget> floatButton(func) async {
  return FloatingActionButton(
    onPressed: () {
      func();
    },
    backgroundColor: MAIN_COLOR, // ボタンの背景色
    child: const Icon(Icons.get_app), // ボタンのアイコン
  );
}

Future<void> reLoad(func) async {
      func();
}
