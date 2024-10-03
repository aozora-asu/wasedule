import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/sharepreference.dart';
import 'package:flutter_calandar_app/frontend/assist_files/data_loader.dart';
import 'package:flutter_calandar_app/frontend/screens/common/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/setting_page/setting_page.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/no_task_page.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/tasklist_sort_category.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import 'tasklist_sort_date.dart';
import 'dart:async';
import 'task_data_manager.dart';

import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import '../common/loading.dart';
import 'add_data_card_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../assist_files/colors.dart';

import "../../../backend/DB/handler/user_info_db_handler.dart";

import "../../../backend/service/email.dart";

class TaskViewPage extends ConsumerStatefulWidget {
  void Function(int) moveToMoodlePage;
  TaskViewPage({
    required this.moveToMoodlePage,
    super.key});

  @override
  TaskViewPageState createState() => TaskViewPageState();
}

class TaskViewPageState extends ConsumerState<TaskViewPage> {
  Future<List<Map<String, dynamic>>>? events;
  late String? urlString;
  TaskDatabaseHelper databaseHelper = TaskDatabaseHelper();
  late bool isButton;
  late bool isLoad;
  bool _isFabVisible = true;

  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey =
      GlobalKey<LiquidPullToRefreshState>();

  @override
  void initState() {
    super.initState();
    ref.read(taskDataProvider).chosenTaskIdList = [];
    isButton = false;
    isLoad = false;
    _initializeData();
  }

  Future<void> _initializeData() async {
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
    final addData = await databaseHelper.getTaskFromDB();
    if (mounted) {
      events = Future.value(addData);
      return addData;
    } else {
      return null;
    }
  }

  void _onScroll(ScrollController pageScrollController){
    // スクロールの方向に応じてFABを表示・非表示にする
    if (pageScrollController.position.userScrollDirection == ScrollDirection.reverse) {
      // 下方向にスクロールした場合
      if (_isFabVisible) {
        setState(() {
          _isFabVisible = false;  // FABを非表示
        });
      }
    } else if (pageScrollController.position.userScrollDirection == ScrollDirection.forward) {
      // 上方向にスクロールした場合
      if (!_isFabVisible) {
        setState(() {
          _isFabVisible = true;  // FABを表示
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    ref.watch(taskPageIndexProvider);
    ref.watch(taskDataProvider.notifier);
    ref.watch(taskDataProvider);
    bool isShowTaskCalendarLine = 
      SharepreferenceHandler().getValue(SharepreferenceKeys.isShowTaskCalendarLine);


    Widget dividerModel = const VerticalDivider(
      width: 2,
      thickness: 1,
      color: Colors.grey,
      indent: 4,
      endIndent: 4,
    );

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: BACKGROUND_COLOR,
        body: Stack(children:[
          Column(children: [
            pageHeader(),
            Expanded(child:
            LiquidPullToRefresh(
                key: _refreshIndicatorKey,
                showChildOpacityTransition: false,
                borderWidth: 2,
                springAnimationDurationInMilliseconds: 500,
                animSpeedFactor: 3,
                onRefresh: () async {
                  if (!isLoad) {
                    isLoad = true;
                    await loadData();
                    isLoad = false;
                    setState(() {});
                  }
                },
                child: pages()
              )
            )
          ]),
          pageHeader()
        ]),
      );
  }

  Widget pageHeader(){
    return  Container(
      decoration: BoxDecoration(
        color:FORGROUND_COLOR,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 2,
            offset: const Offset(0, 0),
          ),
        ]
      ),
      width: SizeConfig.blockSizeHorizontal! *100,
      child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: SizeConfig.blockSizeHorizontal! *100,
              child: Row(children: [
                const SizedBox(width: 5,),
                sortSwitch(),
                simpleSmallButton(
                  "注意事項",
                  () {
                    showDisclaimerDialogue(context);
                  },
                ),
                const Spacer(),
              ]),
            ),
          ),
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
                return const LoadingScreen();
              } else {
                return TaskListByDtEnd(
                  onScroll: _onScroll,
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
                return NoTaskPage(moveToMoodlePage: widget.moveToMoodlePage,);
              } else {
                return TaskListByDtEnd(
                  onScroll: _onScroll,
                  sortedData: sortedTasks);
              }
            } else {
              //DBからのデータがnullの場合
              if (ref.read(taskDataProvider).isRenewed) {
                ConfigDataLoader().initConfig(ref);
                ref
                    .read(calendarDataProvider)
                    .getConfigData(ConfigDataLoader().getConfigDataSource());
                displayDB();
                ref.read(taskDataProvider).isRenewed = false;
              }

              return NoTaskPage(moveToMoodlePage: widget.moveToMoodlePage);
            }
          },
        );

      case 1:
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: events,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              if (ref.read(taskDataProvider).isInit) {
                return const LoadingScreen();
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
        return const LoadingScreen();
    }
  }

  Widget sortSwitch() {
    final taskData = ref.watch(taskDataProvider);
    switch (taskData.taskPageIndex) {
      case 0:
        return simpleSmallButton(
            "期限順",
            () {
              setState(() {
                ref.read(taskDataProvider).taskPageIndex = 1;
              });
            });

      default:
        return simpleSmallButton(
            "カテゴリ別",
            () {
              setState(() {
                ref.read(taskDataProvider).taskPageIndex = 0;
              });
            });
    }
  }
}

void showErrorReportDialogue(context) {
  String text = "";
  bool isChecked = true;
  Message message;
  bool isSuccess;
  String validText = "";
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
                    text = value.replaceAll(RegExp(r'[\s]'), "");
                    validText = "＊内容を入力してください";
                  });
                },
                placeholder: "概要\n(不具合報告の場合、できるだけ詳細にお願いいたします。)",
              ),
              Text(
                text != "" ? "" : validText,
                style: const TextStyle(color: Colors.red),
              ),
              Row(children: [
                CupertinoCheckbox(
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value!;
                      });
                    }),
                const Expanded(
                  child: Text(
                    "アプリ改善に必要な情報を提供する",
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 11.5),
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
                message = Message(content: text);
                isSuccess = await message.sendEmail(isChecked);

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

void showDisclaimerDialogue(context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('注意事項'),
          content: const Text(
            "・課題の公開に条件がある場合\n（例：次の条件に合致しない限り利用できません: 活動「〇〇動画」が完了マークされた場合）\nは、条件を満たした課題のみが反映されます。適宜リロードをお願いします。\n\n・課題に添付されているファイルは取得されません。「課題の詳細」内のMoodleビューからご覧ください。\n\n・課題の〆切日時がMoodle側で更新された場合、反映するにはリロードを行なってください。",
            overflow: TextOverflow.clip,
          ),
          actions: <Widget>[
            buttonModel(() {
              Navigator.of(context).pop();
            }, PALE_MAIN_COLOR, '閉じる', verticalpadding: 10),
          ],
        );
      });
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
              color: FORGROUND_COLOR,
              fontSize: fontSize),
        ));
  }
}
