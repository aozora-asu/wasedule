import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/frontend/screens/common/none_task_page.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/deleted_tasks.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/expired_tasks.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/tasklist_sort_category.dart';

import 'tasklist_sort_date.dart';
import 'dart:async';
import 'task_data_manager.dart';

import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import '../common/loading.dart';
import 'add_data_card_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../assist_files/colors.dart';

import "../../../backend/DB/handler/user_info_db_handler.dart";
import '../../../backend/notify/notify.dart';

class TaskViewPage extends ConsumerStatefulWidget {
  @override
  TaskViewPageState createState() => TaskViewPageState();
}

class TaskViewPageState extends ConsumerState<TaskViewPage> {
  Future<List<Map<String, dynamic>>>? events;
  late String? urlString;
  TaskDatabaseHelper databaseHelper = TaskDatabaseHelper();
  late bool isButton;
  late bool isLoad;

  @override
  void initState() {
    super.initState();
    ref.read(taskDataProvider).chosenTaskIdList = [];
    isButton = false;
    isLoad = false;
    _initializeData();
  }


  Future<void> _initializeData() async {
    //ここの中にロードを1時間に1回までに制限する仕組みを書いて、
    //initState内で呼び出せばよさそうじゃない？
    urlString = await UserDatabaseHelper().getUrl();
    if (await databaseHelper.hasData() || urlString != null) {
      await loadData();
    }
  }

  //データベースを更新する関数。主にボタンを押された時のみ
  Future<void> loadData() async {
    urlString = await UserDatabaseHelper().getUrl();
    if (urlString != null) {
      await databaseHelper.resisterTaskToDB(urlString!);
    }
    NotifyContent().taskDueTodayNotification();
    await displayDB();
  }

  Future<List<Map<String, dynamic>>?> displayDB() async {
    final addData = await databaseHelper.taskListForTaskPage();
    if (mounted) {
      events = Future.value(addData);
      return addData;
    } else {
      return null;
    }
  }



  @override
  Widget build(BuildContext context) {
    ref.watch(taskPageIndexProvider);
    ref.watch(taskDataProvider.notifier);
    ref.watch(taskDataProvider);
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(children: [
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
                      offset: const Offset(0, 1), 
                    ),
                  ],
                ),
                height: SizeConfig.blockSizeVertical! * 4.5,
                child: Row(children: [
                  TextButton(
                    child: Row(children:[
                      const Text("期限切れ ",
                        style:TextStyle(fontWeight: FontWeight.bold)),
                      listLengthView(
                        ref.watch(taskDataProvider).expiredTaskDataList.length,
                        SizeConfig.blockSizeVertical! * 1.205,
                      )
                      ]),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ExpiredTaskPage()),
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
                  TextButton(
                    child: const Text("削除済み",
                      style:TextStyle(fontWeight: FontWeight.bold)),
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
            AddDataCardButton(setosute: setState),
            SizedBox(
              width: SizeConfig.blockSizeHorizontal! * 2,
              height: SizeConfig.blockSizeVertical! * 5,
            ),
            FloatingActionButton(
              heroTag: "task_2",
              onPressed: () async {
                if (isLoad == false) {
                  await loadData();
                  isLoad = true;
                }
              },
              backgroundColor: MAIN_COLOR,
              child: const Icon(Icons.refresh_outlined, color: Colors.white),
            ),
          ],
        ));
  }


  Widget pages() {
    final taskData = ref.watch(taskDataProvider);
    List<Map<String, dynamic>> tempTaskDataList = [];

    switch (ref.read(taskDataProvider).taskPageIndex) {
      case 0:
        return FutureBuilder<List<Map<String, dynamic>>?>(
          future: displayDB(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              if (ref.read(taskDataProvider).isInit) {
                return LoadingScreen();
              } else {
                return TaskListByDtEnd(
                    sortedData:
                        taskData.sortDataByDtEnd(taskData.taskDataList));
              }
            } else if (snapshot.hasError) {
              return const SizedBox();
            } else if (snapshot.hasData) {
              //DBから何らかのデータが返ってきた場合

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

              Map<DateTime, List<Map<String, dynamic>>> sortedTasks =
                  taskData.sortDataByDtEnd(taskData.taskDataList);
              if (sortedTasks.isEmpty) {
                return NoTaskPage();
              } else {
                return TaskListByDtEnd(sortedData: sortedTasks);
              }
            } else {
              //DBからのデータがnullの場合
              if (ref.read(taskDataProvider).isRenewed) {
                displayDB();
                ref.read(taskDataProvider).isRenewed = false;
              }

              return NoTaskPage();
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
                    sortedData:
                        taskData.sortDataByCategory(taskData.taskDataList));
              }
            } else if (snapshot.hasError) {
              return const Text("エラーコード: 503");
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
                  sortedData:
                      taskData.sortDataByCategory(taskData.taskDataList));
            } else {
              //noUrlDialogue(context);
              return TaskListByCategory(
                  sortedData:
                      taskData.sortDataByCategory(taskData.taskDataList));
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
            child: const Text("畳む",
              style:TextStyle(fontWeight: FontWeight.bold)));
      case 1:
        return TextButton(
            onPressed: () {
              setState(() {
                taskData.foldState = 2;
              });
            },
            child: const Text("展開",
              style:TextStyle(fontWeight: FontWeight.bold)));
      default:
        return TextButton(
            onPressed: () {
              setState(() {
                taskData.foldState = 1;
              });
            },
            child: const Text("畳む",
              style:TextStyle(fontWeight: FontWeight.bold)));
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
            child: const Text("ソート：期限",
              style:TextStyle(fontWeight: FontWeight.bold)));
      case 1:
        return TextButton(
            onPressed: () {
              setState(() {
                ref.read(taskDataProvider).taskPageIndex = 0;
              });
            },
            child: const Text("ソート：カテゴリ",
               style:TextStyle(fontWeight: FontWeight.bold)));
      default:
        return TextButton(
            onPressed: () {
              setState(() {
                ref.read(taskDataProvider).taskPageIndex = 0;
              });
            },
            child: const Text("ソート：カテゴリ",
               style:TextStyle(fontWeight: FontWeight.bold)));
    }
  }
}

  Widget listLengthView(int target, double fontSize) {
    if (target == 0) {
      return const SizedBox();
    } else {
      return Container(
          decoration: const BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
          ),
          padding: EdgeInsets.all(fontSize / 3),
          child: Text(
            target.toString(),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: fontSize),
        )
      );
    }
  }

