import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/data_loader.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/common/none_task_page.dart';
import 'package:flutter_calandar_app/frontend/screens/common/tutorials.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/sns_link_page.dart';
import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/moodle_view_page.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/deleted_tasks.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/expired_tasks.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/tasklist_sort_category.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:intl/intl.dart';

import 'tasklist_sort_date.dart';
import 'dart:async';
import 'task_data_manager.dart';

import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import '../common/loading.dart';
import 'add_data_card_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../assist_files/colors.dart';

import "../../../backend/DB/handler/user_info_db_handler.dart";

import "../../../backend/email.dart";

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
    final bottomSpace = MediaQuery.of(context).viewInsets.bottom;
    ConfigDataLoader().initConfig(ref);
    ref
        .read(calendarDataProvider)
        .getConfigData(ConfigDataLoader().getConfigDataSource());

    Widget dividerModel = const VerticalDivider(
      width: 4,
      thickness: 1.5,
      color: Colors.grey,
      indent: 0,
      endIndent: 4,
    );

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Column(children: [
          Row(children: [
            const Icon(Icons.arrow_left, color: Colors.grey),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  height: SizeConfig.blockSizeVertical! * 4.5,
                  child: Row(children: [
                    dividerModel,
                    TextButton(
                      child: Row(children: [
                        const Text("期限切れ ",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        listLengthView(
                          ref
                              .watch(taskDataProvider)
                              .expiredTaskDataList
                              .length,
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
                      child: const Text("お問い合わせ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.red)),
                      onPressed: () {
                        showErrorReportDialogue(context);
                      },
                    ),
                    dividerModel
                  ]),
                ),
              ),
            ),
            const Icon(Icons.arrow_right, color: Colors.grey)
          ]),
          const Divider(thickness: 0.3, height: 0.3, color: Colors.grey),
          Expanded(child: pages())
        ]),
        floatingActionButton: Container(
            margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical! * 9),
            child: Row(
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
                  child:
                      const Icon(Icons.refresh_outlined, color: Colors.white),
                ),
              ],
            )));
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
            child: const Text("期限順",
                style: TextStyle(fontWeight: FontWeight.bold)));

      default:
        return TextButton(
            onPressed: () {
              setState(() {
                ref.read(taskDataProvider).taskPageIndex = 0;
              });
            },
            child: const Text("カテゴリ別",
                style: TextStyle(fontWeight: FontWeight.bold)));
    }
  }
}

void showErrorReportDialogue(context) {
  String _text = "";
  bool _isChecked = true;
  Message message;
  bool isSuccess;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return CupertinoAlertDialog(
          title: const Text('お問い合わせ'),
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
                placeholder: "概要\n(不具合報告の場合、できるだけ詳細にお願いいたします。)",
              ),
              Row(children: [
                CupertinoCheckbox(
                    value: _isChecked,
                    onChanged: (value) {
                      setState(() {
                        _isChecked = value!;
                      });
                    }),
                const Expanded(
                  child: Text(
                    "アプリ改善に必要な情報を提供する",
                    overflow: TextOverflow.clip,
                  ),
                )
              ]),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('閉じる'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('送信'),
              onPressed: () async {
                message = Message(content: _text);
                isSuccess = await message.sendEmail(_isChecked);

                Navigator.of(context).pop();
                if (isSuccess) {
                  showReportDoneDialogue(context);
                } else {
                  showReportFailDialogue("String errorMessage", context);
                }
              },
            ),
          ],
        );
      });
    },
  );
}

void showReportDoneDialogue(context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('不具合レポートが送信されました。'),
        actions: <Widget>[
          const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  "ご報告いただきありがとうございます。\nお寄せいただいた情報はアプリの改善のために役立てさせていただきます。")),
          const SizedBox(height: 10),
          okButton(context, 500.0)
        ],
      );
    },
  );
}

void showReportFailDialogue(String errorMessage, context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('レポート失敗'),
        actions: <Widget>[
          Align(alignment: Alignment.centerLeft, child: Text(errorMessage)),
          const Align(
              alignment: Alignment.centerLeft, child: Text("お手数ですが再度お試しください。")),
          const SizedBox(height: 10),
          okButton(context, 500.0)
        ],
      );
    },
  );
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

Widget indexModel(String text) {
  return Column(children: [
    Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
            fontSize: SizeConfig.blockSizeHorizontal! * 4,
            fontWeight: FontWeight.normal,
            color: Colors.grey),
      ),
    ),
    const Divider(height: 1),
  ]);
}

void bottomSheet(targetData, ref, context, setState) {
  TextEditingController summaryController =
      TextEditingController(text: targetData["summary"] ?? "");
  TextEditingController titleController =
      TextEditingController(text: targetData["title"] ?? "");
  TextEditingController descriptionController =
      TextEditingController(text: targetData["description"] ?? "");
  DateTime dtEnd = DateTime.fromMillisecondsSinceEpoch(targetData["dtEnd"]);
  int id = targetData["id"];
  Widget dividerModel = const Divider(height: 1);
  int _height = (SizeConfig.blockSizeVertical! * 100).round();

  Widget miniSquare = Container(
      height: SizeConfig.blockSizeHorizontal! * 2,
      width: SizeConfig.blockSizeHorizontal! * 2,
      color: MAIN_COLOR);

  showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (BuildContext context) {
      return Stack(alignment: Alignment.bottomCenter, children: [
        Container(
            height: SizeConfig.blockSizeVertical! * 85,
            margin: const EdgeInsets.only(top: 0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SingleChildScrollView(
                primary: false,
                child: Scrollbar(
                  child: Column(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5), // 影の色と透明度
                                spreadRadius: 2, // 影の広がり
                                blurRadius: 4, // 影のぼかし
                                offset: const Offset(0, 2), // 影の方向（横、縦）
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          height: SizeConfig.blockSizeHorizontal! * 13,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: SizeConfig.blockSizeHorizontal! * 4,
                              ),
                              SizedBox(
                                  width: SizeConfig.blockSizeHorizontal! * 92,
                                  child: Row(
                                    children: [
                                      Container(
                                        constraints: BoxConstraints(
                                            maxWidth: SizeConfig
                                                    .blockSizeHorizontal! *
                                                73.5),
                                        child: Text(
                                          targetData["summary"] ?? "(詳細なし)",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  5,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      Text(
                                        "  の詳細",
                                        style: TextStyle(
                                            fontSize: SizeConfig
                                                    .blockSizeHorizontal! *
                                                5,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  )),
                              SizedBox(
                                width: SizeConfig.blockSizeHorizontal! * 4,
                              ),
                            ],
                          )),
                      dividerModel,
                      SizedBox(
                        height: SizeConfig.blockSizeHorizontal! * 1,
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Column(children: [
                            indexModel("■タスク名"),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextField(
                                controller: summaryController,
                                maxLines: null,
                                textInputAction: TextInputAction.done,
                                decoration: const InputDecoration.collapsed(
                                  hintText: "タスク名を入力…",
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal! * 4,
                                    fontWeight: FontWeight.w400),
                                onSubmitted: (value) {
                                  TaskDatabaseHelper().updateSummary(id, value);

                                  final list =
                                      ref.read(taskDataProvider).taskDataList;
                                  final newList = [...list];
                                  ref.read(taskDataProvider.notifier).state =
                                      TaskData();
                                  ref.read(taskDataProvider).isRenewed = true;
                                  //Navigator.pop(context);
                                },
                              ),
                            ),
                            SizedBox(height: SizeConfig.blockSizeVertical! * 2),
                            indexModel("■ カテゴリ"),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextField(
                                controller: titleController,
                                maxLines: 1,
                                decoration: const InputDecoration.collapsed(
                                  hintText: "カテゴリを入力...",
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal! * 4,
                                    fontWeight: FontWeight.w400),
                                onSubmitted: (value) {
                                  TaskDatabaseHelper().updateTitle(id, value);

                                  final list =
                                      ref.read(taskDataProvider).taskDataList;
                                  final newList = [...list];
                                  ref.read(taskDataProvider.notifier).state =
                                      TaskData();
                                  ref.read(taskDataProvider).isRenewed = true;
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            SizedBox(height: SizeConfig.blockSizeVertical! * 2),
                            indexModel("■ 締切日時"),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: GestureDetector(
                                    onTap: () async {
                                      TextEditingController controller =
                                          TextEditingController();
                                      await DateTimePickerFormField(
                                        controller: controller,
                                        labelText: "",
                                        labelColor: MAIN_COLOR,
                                      ).selectDateAndTime(context, ref);
                                      DateTime changedDateTime =
                                          DateTime.parse(controller.text);
                                      int changedDateTimeSinceEpoch =
                                          changedDateTime
                                              .millisecondsSinceEpoch;

                                      await TaskDatabaseHelper().updateDtEnd(
                                          id, changedDateTimeSinceEpoch);

                                      final list = ref
                                          .read(taskDataProvider)
                                          .taskDataList;
                                      final newList = [...list];
                                      ref
                                          .read(taskDataProvider.notifier)
                                          .state = TaskData();
                                      ref.read(taskDataProvider).isRenewed =
                                          true;
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                        DateFormat("yyyy年MM月dd日  HH時mm分")
                                            .format(dtEnd)))),
                            SizedBox(height: SizeConfig.blockSizeVertical! * 2),
                            indexModel("■ タスクの詳細"),
                            TextField(
                              maxLines: null,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (value) {
                                TaskDatabaseHelper()
                                    .updateDescription(id, value);

                                final list =
                                    ref.read(taskDataProvider).taskDataList;
                                final newList = [...list];
                                ref.read(taskDataProvider.notifier).state =
                                    TaskData();
                                ref.read(taskDataProvider).isRenewed = true;
                                Navigator.pop(context);
                              },
                              controller: descriptionController,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal! * 4,
                              ),
                              decoration: const InputDecoration(
                                hintText: "(タスクの詳細やメモを入力…)",
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            SizedBox(height: SizeConfig.blockSizeVertical! * 2),
                            indexModel("■ タスクの削除"),
                            SizedBox(height: SizeConfig.blockSizeVertical! * 1),
                            buttonModelWithChild(() async {
                              TaskDatabaseHelper().unDisplay(id);
                              setState(() {});
                              final list =
                                  ref.read(taskDataProvider).taskDataList;
                              List<Map<String, dynamic>> newList = [...list];
                              ref.read(taskDataProvider.notifier).state =
                                  TaskData(taskDataList: newList);
                              ref.read(taskDataProvider).isRenewed = true;
                              ref.read(taskDataProvider).sortDataByDtEnd(list);
                              setState(() {});
                              Navigator.pop(context);
                            },
                                Colors.red,
                                const Row(
                                  children: [
                                    Spacer(),
                                    Icon(Icons.delete, color: Colors.white),
                                    SizedBox(width: 10),
                                    Text(
                                      "削除",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Spacer()
                                  ],
                                )),
                            SizedBox(
                              height: SizeConfig.blockSizeVertical! * 2,
                            ),
                            indexModel("■ Moodle ページビュー"),
                            SizedBox(
                              height: SizeConfig.blockSizeVertical! * 1,
                            ),
                            // Container(
                            //     width:SizeConfig.blockSizeHorizontal! *100,
                            //     height :SizeConfig.blockSizeVertical! *_height,
                            //     decoration:BoxDecoration(border: Border.all()),
                            //     child:InAppWebView(
                            //       key: webMoodleViewKey,
                            //       initialUrlRequest: URLRequest(

                            //       //ここに課題ページのURLを受け渡し！
                            //         url: WebUri("https://wsdmoodle.waseda.jp/")),

                            //       onWebViewCreated: (controller) {
                            //         webMoodleViewController = controller;
                            //       },
                            //       onLoadStop: (a,b) async{
                            //         _height = await webMoodleViewController?.getContentHeight() ?? 100;
                            //         setState((){});
                            //       },
                            //       onContentSizeChanged:(a,b,c) async{
                            //         _height = await webMoodleViewController?.getContentHeight() ?? 100;
                            //         setState((){});
                            //       },
                            //     )
                            //   ),
                          ]))
                    ],
                  ),
                ))),
        menuBar(),
      ]);
    },
  );
}

Widget menuBar() {
  return Container(
    decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey))),
    //   child:Row(children:[
    //     IconButton(
    //         onPressed: () {
    //           webMoodleViewController?.goBack();
    //         },
    //         icon:Icon(Icons.arrow_back_ios,size:SizeConfig.blockSizeVertical! *2.5,),),
    //     const Spacer(),
    //     IconButton(
    //         onPressed: () {
    //           final url = URLRequest(
    //               url: WebUri("https://wsdmoodle.waseda.jp/"));
    //           webMoodleViewController?.loadUrl(urlRequest: url);
    //         },
    //         icon:Icon(Icons.home,size:SizeConfig.blockSizeVertical! *3,),),
    //     const Spacer(),
    //     IconButton(
    //         onPressed: () {
    //           webMoodleViewController?.goForward();
    //         },
    //         icon:Icon(Icons.arrow_forward_ios,size:SizeConfig.blockSizeVertical! *2.5,),),
    // ])
  );
}
