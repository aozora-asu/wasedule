import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/size_config.dart';
import 'package:flutter_calandar_app/frontend/colors.dart';
import 'package:intl/intl.dart';
import 'package:flutter_calandar_app/frontend/colors.dart';

Widget addDataCardButton() {
  return SizedBox(
    child: FloatingActionButton.extended(
      onPressed: () {
        // データカードを追加する処理をここに記述
      },
      foregroundColor: Colors.white,
      backgroundColor: ACCENT_COLOR,
      isExtended: true,
      label: const Text('タスク追加'),
      icon: const Icon(Icons.add),
    ),
  );
}