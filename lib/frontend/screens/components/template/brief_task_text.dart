import 'package:flutter/material.dart';
import "package:flutter_calandar_app/backend/db_manager.dart";
import 'package:flutter_calandar_app/frontend/screens/pages/calendar_page.dart';
import 'package:flutter_calandar_app/frontend/size_config.dart';
import 'package:flutter_calandar_app/frontend/colors.dart';
import 'package:intl/intl.dart';
import '../../../size_config.dart';

Widget buildTaskText(List<Map<String, dynamic>> taskList) {
  if (taskList.isEmpty) {
    return const Text("現在のタスクはありません");
  }

  String text = "";
  for (int i = 0; i < taskList.length; i++) {
    text +=
        '${DateFormat('【MM/dd HH:mm】').format(DateTime.fromMillisecondsSinceEpoch(taskList[i]["dtEnd"])).toString()} ${taskList[i]["title"]}\n      ${taskList[i]["summary"]}\n\n';
  }
  return SingleChildScrollView(
    child: Text(
      
      text,
      style:  TextStyle(fontSize: SizeConfig.blockSizeHorizontal! * 3.5),
    ),
  );
}
