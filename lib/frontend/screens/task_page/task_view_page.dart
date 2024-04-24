import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/frontend/screens/common/none_task_page.dart';
import 'package:flutter_calandar_app/frontend/screens/common/tutorials.dart';
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
    await NotifyContent().taskDueTodayNotification();
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
    final bottomSpace= MediaQuery.of(context).viewInsets.bottom;

    Widget dividerModel =
      const VerticalDivider(
        width: 4,
        thickness: 1.5,
        color: Colors.grey,
        indent: 0,
        endIndent: 4,
      );

return Scaffold(
  resizeToAvoidBottomInset: false,
  backgroundColor: Colors.white,
  body: Column(
    children: [
      Row(
        children:[
          const Icon(Icons.arrow_left,color:Colors.grey),
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
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

                child: Row(
                  children: [
                    dividerModel,
                    TextButton(
                    child: Row(children:[
                      const Text("期限切れ ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      listLengthView(
                        ref.watch(taskDataProvider).expiredTaskDataList.length,
                        SizeConfig.blockSizeVertical! * 1.205,
                      )
                    ]),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ExpiredTaskPage(setosute: setState)),
                      );
                    },
                  ),
                  dividerModel,
                  TextButton(
                    child: const Text("削除済み",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                DeletedTaskPage(setosute: setState)),
                      );
                    },
                  ),
                  dividerModel,
                  Align(
                    alignment: Alignment.centerLeft,
                    child: foldStateSwitch(),
                  ),
                  dividerModel,
                  sortSwitch(),
                  dividerModel,
                  TextButton(
                    child: const Text("不具合報告",
                      style:TextStyle(fontWeight: FontWeight.bold,color:Colors.red)),
                    onPressed: () {
                      showErrorReportDialogue();
                    },
                  ),
                  dividerModel
                ]),
              ),
            ),
          ),
          const Icon(Icons.arrow_right,color:Colors.grey)
        ]),
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
        )
      );
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
                style: TextStyle(fontWeight: FontWeight.bold)));
      case 1:
        return TextButton(
            onPressed: () {
              setState(() {
                taskData.foldState = 2;
              });
            },
            child: const Text("展開",
                style: TextStyle(fontWeight: FontWeight.bold)));
      default:
        return TextButton(
            onPressed: () {
              setState(() {
                taskData.foldState = 1;
              });
            },
            child: const Text("畳む",
                style: TextStyle(fontWeight: FontWeight.bold)));
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
                style: TextStyle(fontWeight: FontWeight.bold)));

      case 1:
        return TextButton(
            onPressed: () {
              setState(() {
                ref.read(taskDataProvider).taskPageIndex = 0;
              });
            },

            child: const Text("ソート：カテゴリ",
                style: TextStyle(fontWeight: FontWeight.bold)));

      default:
        return TextButton(
            onPressed: () {
              setState(() {
                ref.read(taskDataProvider).taskPageIndex = 0;
              });
            },

            child: const Text("ゴリゴリ別",
               style:TextStyle(fontWeight: FontWeight.bold)));

    }
  }

  void showErrorReportDialogue(){
    String _text = "";
    bool _isChecked = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context,setState){
          return CupertinoAlertDialog(
          title:const Text('不具合を報告する'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CupertinoTextField(
                maxLines: 5,
                textInputAction: TextInputAction.done,
                onChanged: (value) {
                  setState(() {
                    _text = value;
                  });
                },
                placeholder:"不具合の概要\n(できるだけ詳細にお願いいたします。)",
              ),
              Row(children:[
                CupertinoCheckbox(
                  value: _isChecked,
                  onChanged:(value){
                  setState(() {
                    _isChecked = value!;
                  });
                }),
                const Expanded(child:
                 Text("デバッグのための情報を提供する",
                  overflow: TextOverflow.clip,),)
              ]),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child:const Text('閉じる'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child:const Text('送信'),
              onPressed: () {
              //ここにデバッグ情報を送信する処理を記述！！
              //_isCheckedは同意があるかどうか
              //_textはエラーの詳細


                Navigator.of(context).pop();
                showReportDoneDialogue();
                showReportFailDialogue("String errorMessage");
              },
            ),
          ],
         );
        }
       );  
      },
    );
  }

  void showReportDoneDialogue() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('不具合レポートが送信されました。'),
          actions: <Widget>[
            const Align(alignment: Alignment.centerLeft, child: Text("ご報告いただきありがとうございます。\nお寄せいただいた情報はアプリの改善のために役立てさせていただきます。")),
            const SizedBox(height: 10),
            okButton(context, 500.0)
          ],
        );
      },
    );
  }

  void showReportFailDialogue(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('レポート失敗'),
          actions: <Widget>[
            Align(alignment: Alignment.centerLeft, child: Text(errorMessage)),
            const Align(alignment: Alignment.centerLeft, child: Text("お手数ですが再度お試しください。")),
            const SizedBox(height: 10),
            okButton(context, 500.0)
          ],
        );
      },
    );
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
        ));
  }
}
