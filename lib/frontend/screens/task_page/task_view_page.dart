import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/none_task_page.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/deleted_tasks.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/tasklist_sort_category.dart';

import 'tasklist_sort_date.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'data_manager.dart';

import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import '../common/loading.dart';
import 'add_data_card_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../assist_files/colors.dart';

import "../../../backend/DB/handler/user_info_db_handler.dart";

class TaskViewPage extends ConsumerStatefulWidget {
  @override
  TaskViewPageState createState() => TaskViewPageState();
}

class TaskViewPageState extends ConsumerState<TaskViewPage> {
  Future<List<Map<String, dynamic>>>? events;
  late String? urlString;
  TaskDatabaseHelper databaseHelper = TaskDatabaseHelper();
  late bool isButton;

  @override
  void initState() {
    super.initState();
    _initializeData();
    ref.read(taskDataProvider).chosenTaskIdList = [];
    isButton = false;
  }

  Future<void> _initializeData() async {
    urlString = await UserDatabaseHelper().getUrl();
    NoTaskPage();
  }

  //データベースを更新する関数。主にボタンを押された時のみ
  Future<void> loadData() async {
    if (urlString != null) {
      await databaseHelper.resisterTaskToDB(urlString!);
      await displayDB();
    }
  }

  Future<void> displayDB() async {
    final addData = await databaseHelper.taskListForTaskPage();
    if (mounted) {
      setState(() {
        events = Future.value(addData);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskData = ref.watch(taskDataProvider);
    ref.watch(taskPageIndexProvider);
    ref.watch(taskDataProvider.notifier);
    ref.watch(taskDataProvider);
    return Scaffold(
        backgroundColor: Colors.white, // BACKGROUND_COLOR,
        body: 
            Column(children: [
          SizedBox(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1), // 影のオフセット（x, y）
                    ),
                  ],
                ),
                height: SizeConfig.blockSizeVertical! * 4.5,
                child: Row(children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: foldStateSwitch(),
                  ),
                  const VerticalDivider(
                    width: 4,
                    thickness: 1.5,
                    color: Colors.grey,
                    indent: 0,
                    endIndent: 4,
                  ),
                  TextButton(
                    child: const Text("削除済み"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DeletedTaskPage()),
                      );
                    },
                  ),
                  const VerticalDivider(
                    width: 4,
                    thickness: 1.5,
                    color: Colors.grey,
                    indent: 0,
                    endIndent: 4,
                  ),
                  sortSwitch(),
                  SizedBox(width: SizeConfig.blockSizeHorizontal! * 60)
                ]),
              ),
            ),
          ),
          const Divider(thickness: 0.3, height: 0.3, color: Colors.grey),
          Expanded(child: pages())
        ]),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AddDataCardButton(),
            Container(
              width: SizeConfig.blockSizeHorizontal! * 2,
              height: SizeConfig.blockSizeVertical! * 5,
            ),
            FloatingActionButton(
              onPressed: () {
                loadData();
              },
              backgroundColor: MAIN_COLOR,
              child: const Icon(Icons.get_app, color: Colors.white),
            ),
          ],
        ));
  }

  Widget pages() {
    final taskData = ref.watch(taskDataProvider);
    List<Map<String, dynamic>> tempTaskDataList = [];

    switch (ref.read(taskDataProvider).taskPageIndex) {
      case 0:
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: events,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              if (ref.read(taskDataProvider).isInit) {
                return LoadingScreen();
              } else {
                return TaskListByDtEnd(
                    sortedData: taskData.sortDataByDtEnd(taskData.taskDataList));
              }
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else if (snapshot.hasData) {
              if (ref.watch(taskDataProvider).isInit) {
                ref.read(taskDataProvider).isInit = false;
              }

              tempTaskDataList = snapshot.data!.toList();

              // for(int i=0; i<tempTaskDataList.length; i++){
              // tempTaskDataList[i]["DBindex"] = i;
              // }

              taskData.getData(tempTaskDataList);

              if (ref.read(taskDataProvider).isRenewed) {
                displayDB();
                ref.read(taskDataProvider).isRenewed = false;
              }

              taskData.sortDataByDtEnd(taskData.taskDataList);
              return TaskListByDtEnd(
                  sortedData: taskData.sortDataByDtEnd(taskData.taskDataList));
            } else {
              //noUrlDialogue(context);
              return NoTaskPage();
              // TaskListByDtEnd(
              //     sortedData: taskData.sortDataByDtEnd(taskData.taskDataList));

            }
          },
        );

      case 1:
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: events,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              if (ref.read(taskDataProvider).isInit) {
                return LoadingScreen();
              } else {
                return TaskListByCategory(
            sortedData: taskData.sortDataByCategory(taskData.taskDataList));
              }
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else if (snapshot.hasData) {
              if (ref.watch(taskDataProvider).isInit) {
                ref.read(taskDataProvider).isInit = false;
              }

              tempTaskDataList = snapshot.data!.toList();

              // for(int i=0; i<tempTaskDataList.length; i++){
              // tempTaskDataList[i]["DBindex"] = i;
              // }

              taskData.getData(tempTaskDataList);

              if (ref.read(taskDataProvider).isRenewed) {
                displayDB();
                ref.read(taskDataProvider).isRenewed = false;
              }

              taskData.sortDataByDtEnd(taskData.taskDataList);
              return TaskListByCategory(
            sortedData: taskData.sortDataByCategory(taskData.taskDataList));
            } else {
              //noUrlDialogue(context);
              return TaskListByCategory(
            sortedData: taskData.sortDataByCategory(taskData.taskDataList));
            }
          },
        );

      default:
        return LoadingScreen();
    }
  }

  Widget foldStateSwitch() {
    final taskData = ref.watch(taskDataProvider);
    switch (taskData.foldState) {
      case 0:
        return TextButton(
            onPressed: () {
              setState(() {
                taskData.foldState = 1;
              });
            },
            child: const Text("全て畳む"));
      case 1:
        return TextButton(
            onPressed: () {
              setState(() {
                taskData.foldState = 2;
              });
            },
            child: const Text("全て展開する"));
      case 2:
        return TextButton(
            onPressed: () {
              setState(() {
                taskData.foldState = 0;
              });
            },
            child: const Text("期限内のみ展開する"));
      default:
        return TextButton(
            onPressed: () {
              setState(() {
                taskData.foldState = 0;
              });
            },
            child: const Text("期限内のみ展開する"));
    }
  }

  Widget sortSwitch() {
    final taskData = ref.watch(taskDataProvider);
    switch (taskData.taskPageIndex) {
      case 0:
        return TextButton(
            onPressed: () {
              setState(() {
                ref.read(taskDataProvider).taskPageIndex = 1;
              });
            },
            child: const Text("ソート：期限"));
      case 1:
        return TextButton(
            onPressed: () {
              setState(() {
                ref.read(taskDataProvider).taskPageIndex = 0;
              });
            },
            child: const Text("ソート：カテゴリ"));
      default:
        return TextButton(
            onPressed: () {
              setState(() {
                ref.read(taskDataProvider).taskPageIndex = 0;
              });
            },
            child: const Text("ソート：ゴリゴリ"));
    }
  }
}
