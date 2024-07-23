import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'dart:async';
import 'package:expandable/expandable.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';

import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_modal_sheet.dart';

import 'task_data_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "../../../backend/DB/sharepreference.dart";
import 'package:intl/intl.dart';

class TaskListByDtEnd extends ConsumerStatefulWidget {
  Map<DateTime, List<Map<String, dynamic>>> sortedData = {};
  TaskListByDtEnd({super.key, required this.sortedData});
  @override
  _TaskListByDtEndState createState() => _TaskListByDtEndState();
}

class _TaskListByDtEndState extends ConsumerState<TaskListByDtEnd> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final taskData = ref.watch(taskDataProvider);
    Map<DateTime, List<Map<String, dynamic>>> sortedData = widget.sortedData;
    sortedData = taskData.sortDataByDtEnd(taskData.taskDataList);
    ref.watch(taskDataProvider.notifier);
    ref.watch(taskDataProvider);
    return Scrollbar(
        child: Stack(children: [
      Column(children: [
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int keyIndex) {
              DateTime dateEnd = sortedData.keys.elementAt(keyIndex);
              dateEnd = DateTime.fromMillisecondsSinceEpoch(
                  sortedData.values.elementAt(keyIndex).first["dtEnd"]);
              String adjustedDtEnd =
                  ("${dateEnd.month}月${dateEnd.day}日 (${"日月火水木金土日"[dateEnd.weekday % 7]}) ");
              return Container(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, bottom: 0.0, top: 4.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExpandablePanel(
                            header: Row(children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      const SizedBox(width: 5),
                                      Text(
                                        adjustedDtEnd,
                                        style:const TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.w800,
                                            color: BLUEGREY),
                                      ),
                                    ]),
                                    const SizedBox(height: 5),
                                    remainingTime(dateEnd)
                                  ]),
                            ]),
                            collapsed: const SizedBox(),
                            expanded: dtEndTaskGroup(
                              keyIndex,
                            ),
                            controller:
                                ExpandableController(initialExpanded: true)),
                        const Divider(
                            thickness: 1,
                            indent: 3,
                            endIndent: 3,
                            color: Colors.transparent)
                      ]));
            },
            itemCount: sortedData.keys.length,
          ),
        )
      ]),
      executeDeleteButton()
    ]));
  }

  bool isLimitOver(
      DateTime dtEnd,
      Map<DateTime, List<Map<String, dynamic>>> sortedData,
      DateTime keyDateTime) {
    DateTime timeLimit = dtEnd;
    List<int> containedIdList = [];
    for (int i = 0; i < sortedData[keyDateTime]!.length; i++) {
      containedIdList.add(sortedData[keyDateTime]!.elementAt(i)["id"]);
    }
    List<dynamic> chosenIdList = ref.watch(taskDataProvider).chosenTaskIdList;

    // 2つのリストを集合に変換
    Set<dynamic> set1 = containedIdList.toSet();
    Set<dynamic> set2 = chosenIdList.toSet();

    // 2つの集合の共通要素を検索
    Set<dynamic> intersection = set1.intersection(set2);

    // 共通要素があればtrueを返す
    if (intersection.isNotEmpty) {
      return true;
    } else {
      switch (ref.watch(taskDataProvider).foldState) {
        case 0:
          if (timeLimit
              .isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
            return false;
          } else {
            return true;
          }
        case 1:
          return false;
        case 2:
          return true;
        default:
          return true;
      }
    }
  }

  Widget executeDeleteButton() {
    ref.watch(taskDataProvider);
    if (ref.read(taskDataProvider).isButton) {
      return InkWell(
          onTap: () {
            setState(() {
              for (int i = 0;
                  i < ref.watch(taskDataProvider).chosenTaskIdList.length;
                  i++) {
                int targetId =
                    ref.watch(taskDataProvider).chosenTaskIdList.elementAt(i);
                TaskDatabaseHelper().unDisplay(targetId);
              }
            });
            final list = ref.read(taskDataProvider).taskDataList;
            final newList = [...list];
            ref.read(taskDataProvider.notifier).state =
                TaskData(taskDataList: newList);
            ref.read(taskDataProvider).isRenewed = true;
            ref.read(taskDataProvider).sortDataByDtEnd(list);
            setState(() {});
          },
          child: Container(
            width: SizeConfig.blockSizeHorizontal! * 100,
            height: SizeConfig.blockSizeVertical! * 10,
            color: Colors.redAccent,
            child: Row(children: [
              const Spacer(),
              checkedListLength(15.0),
              const SizedBox(width: 15),
              Icon(Icons.delete, color: FORGROUND_COLOR),
              Text(
                "   Done!!!   ",
                style: TextStyle(
                    color: FORGROUND_COLOR, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.delete, color: FORGROUND_COLOR),
              const Spacer(),
            ]),
          ));
    } else {
      return Container(height: 0);
    }
  }

  Widget checkedListLength(fontSize) {
    final taskData = ref.watch(taskDataProvider);

    return Container(
        decoration: BoxDecoration(
          color: FORGROUND_COLOR,
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(fontSize / 3),
        child: Text(
          (taskData.chosenTaskIdList.length ?? 0).toString(),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.pinkAccent,
              fontSize: fontSize),
        ));
  }

  Stream<String> getRemainingTimeStream(DateTime dtEnd) async* {
    while (dtEnd.isAfter(DateTime.now())) {
      Duration remainingTime = dtEnd.difference(DateTime.now());

      int days = remainingTime.inDays;
      int hours = (remainingTime.inHours % 24);
      int minutes = (remainingTime.inMinutes % 60);
      int seconds = (remainingTime.inSeconds % 60);

      yield '  あと$days 日 $hours時間 $minutes分 $seconds秒  ';

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  StreamBuilder<String> repeatdaysLeft(DateTime dtEnd) {
    return StreamBuilder<String>(
      stream: getRemainingTimeStream(dtEnd),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(
            snapshot.data!,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: FORGROUND_COLOR,
            ),
          );
        } else {
          return const SizedBox(); // データがない場合は何も表示しない
        }
      },
    );
  }

  String getRemainingTime(DateTime dtEnd) {
    Duration remainingTime = dtEnd.difference(DateTime.now());

    int days = remainingTime.inDays;
    int hours = (remainingTime.inHours % 24);
    int minutes = (remainingTime.inMinutes % 60);
    int seconds = (remainingTime.inSeconds % 60);

    return '   あと$days日 $hours時間 $minutes分 $seconds秒  ';
  }

  Widget remainingTime(DateTime dtEnd) {
    double fontSize = 17;
    DateTime timeLimit = dtEnd;
    Duration difference = dtEnd.difference(DateTime.now());
    if (timeLimit.isBefore(DateTime.now()) == false) {
      if (difference >= const Duration(days: 4)) {
        return Container(
            decoration: BoxDecoration(
              color: BLUEGREY,
              borderRadius: BorderRadius.circular(6), // 角丸にする場合は設定
            ),
            child: Text(
              ("  あと${difference.inDays + 1} 日  "),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: FORGROUND_COLOR,
              ),
            )); // 日数の差を出力
      } else {
        return Container(
            decoration: BoxDecoration(
              color: Colors.redAccent, // 背景色を指定
              borderRadius: BorderRadius.circular(6), // 角丸にする場合は設定
            ),
            child: repeatdaysLeft(dtEnd));
      }
    } else if (dtEnd.year == DateTime.now().year &&
        dtEnd.month == DateTime.now().month &&
        dtEnd.day == DateTime.now().day) {
      return Container(
          decoration: BoxDecoration(
            color: Colors.red, // 背景色を指定
            borderRadius: BorderRadius.circular(6), // 角丸にする場合は設定
          ),
          child: Text(
            ("  今日まで  "),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: FORGROUND_COLOR,
            ),
          )); // 日数の差を出力
    } else {
      return Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0, 0, 0), // 背景色を指定
            borderRadius: BorderRadius.circular(6), // 角丸にする場合は設定
          ),
          child: Text(
            ' 期限切れ ',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: FORGROUND_COLOR,
            ),
          ));
    }
  }

  Widget dtEndTaskGroup(keyIndex) {
    ref.watch(taskDataProvider.notifier);
    ref.watch(taskDataProvider);
    return Container(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int valueIndex) {
          return Container(child: dtEndTaskChild(keyIndex, valueIndex));
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: 2);
        },
        itemCount: widget
            .sortedData[widget.sortedData.keys.elementAt(keyIndex)]!.length,
      ),
    );
  }

  Widget dtEndTaskChild(keyIndex, valueIndex) {
    ref.watch(taskDataProvider.notifier);
    ref.watch(taskDataProvider);
    final taskData = ref.watch(taskDataProvider);
    DateTime dateEnd = widget.sortedData.keys.elementAt(keyIndex);
    List<Map<String, dynamic>> childData = widget.sortedData[dateEnd]!;
    Map<String, dynamic> targetData = childData.elementAt(valueIndex);
    BorderRadius radius = const BorderRadius.all(Radius.circular(2));
    bool isChosen = taskData.chosenTaskIdList.contains(targetData["id"]);
    EdgeInsets boxInset = const EdgeInsets.only(left: 8.0, right: 8.0);

    if (valueIndex == 0 && valueIndex == childData.length - 1) {
      radius = const BorderRadius.all(Radius.circular(20));
      boxInset = const EdgeInsets.only(left: 8.0, right: 8.0, top: 12.0);
    } else if (valueIndex == 0) {
      radius = const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(2),
        bottomRight: Radius.circular(2),
      );
      boxInset = const EdgeInsets.only(left: 8.0, right: 8.0, top: 12.0);
    } else if (valueIndex == childData.length - 1) {
      radius = const BorderRadius.only(
        topLeft: Radius.circular(2),
        topRight: Radius.circular(2),
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      );
    }

    Widget draftIndicator = makeDraftIndicator(targetData);

    return Row(children: [
      SizedBox(
          width: 50,
          child: 
            Text(
              DateFormat("HH:mm").format(
                  DateTime.fromMicrosecondsSinceEpoch(targetData["dtEnd"])),
              textAlign: TextAlign.center,
              style:const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: BLUEGREY))),
      Expanded(
          child: InkWell(
              onTap: () async {
                await bottomSheet(context, targetData, setState);
              },
              child: Container(
                  padding: boxInset,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: FORGROUND_COLOR,
                      borderRadius: radius,
                    ),
                    child: Column(children: [
                      Row(children: [
                        CupertinoCheckbox(
                            value: isChosen,
                            onChanged: (value) {
                              var chosenTaskIdList =
                                  ref.watch(taskDataProvider).chosenTaskIdList;
                              setState(() {
                                isChosen = value ?? false;
                                if (chosenTaskIdList
                                    .contains(targetData["id"])) {
                                  ref
                                      .read(taskDataProvider)
                                      .chosenTaskIdList
                                      .remove(targetData["id"]);
                                } else {
                                  ref
                                      .read(taskDataProvider)
                                      .chosenTaskIdList
                                      .add(targetData["id"]);
                                }
                                //ref.read(taskDataProvider.notifier).state;
                                ref.read(taskDataProvider).manageIsButton();
                              });
                            }),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    child: Text(
                                        targetData["summary"] ?? "(詳細なし)",
                                        style:const TextStyle(
                                              fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: BLACK))),
                                SizedBox(
                                    child:
                                        Text(targetData["title"] ?? "(タイトルなし)",
                                            style:const TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey,
                                            ))),
                                draftIndicator
                              ]),
                        )
                      ]),
                    ]),
                  ))))
    ]);
  }

  Widget makeDraftIndicator(Map<String, dynamic> targetData) {
    // String? memoData = SharepreferenceHandler()
    //     .getValue(targetData["id"].toString()) as String;
    String? memoData = targetData["memo"];
    if (memoData != null && memoData != "") {
      return const Row(children: [
        const Spacer(),
        const Text("💬下書きあり",
            style: TextStyle(
                color: BLUEGREY,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
        // Text("/ " + memoData.length.toString() + "字",
        //   style:TextStyle(
        //     color: Colors.grey,
        //     fontSize: SizeConfig.blockSizeHorizontal! *3
        // )),
      ]);
    } else {
      return const SizedBox();
    }
  }

  bool isEditingText(TextEditingController controller) {
    return controller.text.isNotEmpty;
  }
}
