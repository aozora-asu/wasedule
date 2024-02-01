import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:intl/intl.dart';
import '../../../backend/DB/handler/task_db_handler.dart';

Widget buildTaskText(
    List<Map<String, dynamic>> taskList, BuildContext context) {
  SizeConfig().init(context);
  if (taskList.isEmpty) {
    return const Text("現在のタスクはありません");
  }

  return ListView(children: [
    for (int i = 0; i < taskList.length; i++)
      if (taskList[i]["isDone"] == 0 &&
          DateTime.fromMillisecondsSinceEpoch(taskList[i]["dtEnd"])
                  .isBefore(DateTime.now()) ==
              false)
        Column(children: [
          Container(
              alignment: Alignment.centerLeft,
              child: Text(
                '${DateFormat('【MM/dd】 HH:mm  ').format(DateTime.fromMillisecondsSinceEpoch(taskList[i]["dtEnd"])).toString()} ${taskList[i]["title"]}\n      ${taskList[i]["summary"]}',
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

class BriefTaskList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Column(children: [
      Card(
          color: const Color.fromARGB(255, 254, 230, 230),
          child: SizedBox(
              height: SizeConfig.blockSizeHorizontal! * 60,
              width: SizeConfig.blockSizeHorizontal! * 98,
              child: Column(children: [
                Text(
                  ' ～現在のタスク～',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal! * 3.5,
                    fontWeight: FontWeight.w800,
                    color: const Color.fromARGB(255, 77, 46, 35),
                  ),
                ),
                Container(
                    height: SizeConfig.blockSizeHorizontal! * 50,
                    width: SizeConfig.blockSizeHorizontal! * 96,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                        ),
                        BoxShadow(
                          color: Colors.white,
                          spreadRadius: -1.5,
                          blurRadius: 2.0,
                        ),
                      ],
                    ),
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: TaskDatabaseHelper().taskListForCalendarPage(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // 読み込み中の場合、ProgressIndicator を表示
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          // エラーがある場合、エラーメッセージを表示
                          return Text("Error: ${snapshot.error}");
                        } else {
                          // データがある場合、buildTaskText 関数を呼び出してデータを表示
                          return buildTaskText(snapshot.data ?? [], context);
                        }
                      },
                    ))
              ])))
    ]);
  }
}
