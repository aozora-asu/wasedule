import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/sns_link_page.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_view_page.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/tasklist_sort_date.dart';
import 'package:intl/intl.dart';

import 'package:expandable/expandable.dart';

import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'task_data_manager.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskListByCategory extends ConsumerStatefulWidget {
  Map<String, List<Map<String, dynamic>>> sortedData = {};
  TaskListByCategory({required this.sortedData});
  @override
  _TaskListByCategoryState createState() => _TaskListByCategoryState();
}

class _TaskListByCategoryState extends ConsumerState<TaskListByCategory> {
  late bool isInit;
  @override
  void initState() {
    super.initState();
    isInit = true;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final taskData = ref.watch(taskDataProvider);
    Map<String, List<Map<String, dynamic>>> sortedData = widget.sortedData;
    sortedData = taskData.sortDataByCategory(taskData.taskDataList);
    ref.watch(taskDataProvider.notifier);
    ref.watch(taskDataProvider);
    return Scrollbar(
        child: 
      Stack(children:[
      Column(children: [
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int keyIndex) {
              String categoryName = sortedData.keys.elementAt(keyIndex);

            return Container(
                width: SizeConfig.blockSizeHorizontal! * 100,
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
                                    SizedBox(
                                      width:
                                          SizeConfig.blockSizeHorizontal! * 73,
                                      child: Text(
                                        categoryName,
                                        style: TextStyle(
                                            fontSize: SizeConfig
                                                    .blockSizeHorizontal! *
                                                6,
                                            fontWeight: FontWeight.w800),
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                    Text(
                                        " ${sortedData.values.elementAt(keyIndex).length}件",
                                        style: TextStyle(
                                            fontSize: SizeConfig
                                                    .blockSizeHorizontal! *
                                                4.25,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey))
                                  ]),
                                ]),
                          ]),
                          collapsed: const SizedBox(),
                          expanded: categoryTaskGroup(
                            keyIndex,
                          ),
                          controller: ExpandableController(
                              initialExpanded:
                                  isLimitOver(sortedData, categoryName))),
                      const Divider(
                        thickness: 2,
                        indent: 0,
                        endIndent: 0,
                      )
                    ]));
          },
          itemCount: sortedData.keys.length,
        ),
      )
    ]),
    executeDeleteButton()
   ])
  );
  }

  bool isLimitOver(
      Map<String, List<Map<String, dynamic>>> sortedData, String category) {
    List<int> containedIdList = [];
    for (int i = 0; i < sortedData[category]!.length; i++) {
      containedIdList.add(sortedData[category]!.elementAt(i)["id"]);
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
          return false;
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
            setState((){});
          },
          child: Container(
            width: SizeConfig.blockSizeHorizontal! * 100,
            height: SizeConfig.blockSizeVertical! * 10,
            color: Colors.redAccent,
            child: Row(children: [
              const Spacer(),
              checkedListLength(15.0),
              const SizedBox(width: 15),
              const Icon(Icons.delete, color: WHITE),
              const Text(
                "   Done!!!   ",
                style:
                    TextStyle(color: WHITE, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.delete, color: WHITE),
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
        decoration: const BoxDecoration(
          color: WHITE,
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

  Widget categoryTaskGroup(keyIndex) {
    ref.watch(taskDataProvider.notifier);
    ref.watch(taskDataProvider);
    return Container(
      width: SizeConfig.blockSizeHorizontal! * 100,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int valueIndex) {
          return Container(child: categoryTaskChild(keyIndex, valueIndex));
        },
        itemCount: widget
            .sortedData[widget.sortedData.keys.elementAt(keyIndex)]!.length,
      ),
    );
  }

  Widget categoryTaskChild(keyIndex, valueIndex) {
    ref.watch(taskDataProvider.notifier);
    ref.watch(taskDataProvider);
    final taskData = ref.watch(taskDataProvider);
    String category = widget.sortedData.keys.elementAt(keyIndex);
    List<Map<String, dynamic>> childData = widget.sortedData[category]!;
    Map<String, dynamic> targetData = childData.elementAt(valueIndex);

    bool isChosen = taskData.chosenTaskIdList.contains(targetData["id"]);

    return Row(children: [
      InkWell(
          onTap: () {
            bottomSheet(targetData,ref,context,setState);
          },
          child: Container(
              constraints: BoxConstraints(
                maxWidth: SizeConfig.blockSizeHorizontal! * 94,
              ),
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
              child: Container(
                  decoration: BoxDecoration(
                      color: WHITE,
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      border: Border.all(color:Colors.grey,width: 1)
                      ),
                  child: Row(children: [
                    CupertinoCheckbox(
                        value: isChosen,
                        onChanged: (value) {
                          var chosenTaskIdList =
                              ref.watch(taskDataProvider).chosenTaskIdList;
                          setState(() {
                            isChosen = value ?? false;
                            if (chosenTaskIdList.contains(targetData["id"])) {
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
                            ref.read(taskDataProvider).manageIsButton();
                          });
                        }),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              width: SizeConfig.blockSizeHorizontal! * 69,
                              child: Text(targetData["summary"] ?? "(詳細なし)",
                                  style: TextStyle(
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal! * 4.5,
                                      fontWeight: FontWeight.w700))),
                          Row(children: [
                            Text(truncateDtEnd(targetData),
                                style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal! * 4,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey)),
                            const SizedBox(width: 10),
                            Text(truncateTimeEnd(targetData),
                                style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal! * 4,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey)),
                          ])
                        ]),
                  ]))))
    ]);
  }


  bool isEditingText(TextEditingController controller) {
    return controller.text.isNotEmpty;
  }

  String truncateTimeEnd(targetData) {
    String hour = DateTime.fromMillisecondsSinceEpoch(targetData["dtEnd"])
        .hour
        .toString();
    String minute = DateTime.fromMillisecondsSinceEpoch(targetData["dtEnd"])
        .minute
        .toString();

    String formattedhour = hour.padLeft(2, '0');
    String formattedminute = minute.padLeft(2, '0');

    return formattedhour + ":" + formattedminute;
  }

  String truncateDtEnd(targetData) {
    String dtEnd = DateFormat('yyyy/MM/dd')
        .format(DateTime.fromMillisecondsSinceEpoch(targetData["dtEnd"]));
    return dtEnd;
  }
}
