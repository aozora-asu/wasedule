import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/size_config.dart';
import 'package:flutter_calandar_app/frontend/colors.dart';
import 'package:intl/intl.dart';

Widget buildTaskText(
    List<Map<String, dynamic>> taskList, BuildContext context) {
  SizeConfig().init(context);
  if (taskList.isEmpty) {
    return const Text("現在のタスクはありません");
  }

  return ListView(children: [
    for (int i = 0; i < taskList.length; i++)
      if (taskList[i]["isDone"] == 0)
        Column(children: [
          Container(
              alignment: Alignment.centerLeft,
              child: Text(
                '${DateFormat('【MM/dd HH:mm】').format(DateTime.fromMillisecondsSinceEpoch(taskList[i]["dtEnd"])).toString()} ${taskList[i]["title"]}\n      ${taskList[i]["summary"]}',
                style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal! * 3),
              )),
          Divider(
            height: SizeConfig.blockSizeHorizontal! * 3,
            color: WIDGET_OUTLINE_COLOR,
            thickness: 2,
          ),
        ])
  ]);
}
