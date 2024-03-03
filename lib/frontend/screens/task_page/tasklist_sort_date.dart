import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_view_page.dart';
import '../common/float_button.dart';
import '../to_do_page/task_progress_indicator.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:expandable/expandable.dart';

import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import '../common/loading.dart';
import 'add_data_card_button.dart';
import 'data_manager.dart';

import '../../assist_files/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskListByDtEnd extends ConsumerStatefulWidget {
  Map<DateTime, List<Map<String, dynamic>>> sortedData = {};
  TaskListByDtEnd({required this.sortedData});
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
      child:Column(children:[
        executeDeleteButton(),
        Expanded(
        child: ListView.builder(
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int keyIndex) {
          DateTime dateEnd = sortedData.keys.elementAt(keyIndex);
          String adjustedDtEnd =
              ("${dateEnd.month}月${dateEnd.day}日 ${getDayOfWeek(dateEnd.weekday - 1)} ");
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
                                  Text(
                                    adjustedDtEnd,
                                    style: TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal! * 7,
                                        fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                      " ${sortedData.values.elementAt(keyIndex).length}件",
                                      style: TextStyle(
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal! *
                                                  4.25,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey))
                                ]),
                                remainingTime(dateEnd)
                              ]),
                        ]),
                        collapsed: const SizedBox(),
                        expanded: dtEndTaskGroup(keyIndex,),
                        controller: ExpandableController(
                            initialExpanded:
                                isLimitOver(dateEnd, sortedData, dateEnd))),
                    const Divider(
                      thickness: 2.5,
                      indent: 7,
                      endIndent: 7,
                    )
                  ]));
        },
        itemCount: sortedData.keys.length,
      ),
    )]) );
  }

  bool isLimitOver(
      DateTime dtEnd,
      Map<DateTime, List<Map<String, dynamic>>> sortedData,
      DateTime keyDateTime) {
    DateTime timeLimit = dtEnd;
    List<int> containedIdList = [];
    for(int i = 0; i < sortedData[keyDateTime]!.length; i++){
      containedIdList.add(sortedData[keyDateTime]!.elementAt(i)["id"]);
    }
    List<dynamic> chosenIdList = ref.watch(taskDataProvider).chosenTaskIdList;

      // 2つのリストを集合に変換
    Set<dynamic> set1 = containedIdList.toSet();
    Set<dynamic> set2 = chosenIdList.toSet();

    // 2つの集合の共通要素を検索
    Set<dynamic> intersection = set1.intersection(set2);

    // 共通要素があればtrueを返す
    if(intersection.isNotEmpty){
      return true;
    
     }else{
       
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


  Widget executeDeleteButton(){
    ref.watch(taskDataProvider);
    if(ref.read(taskDataProvider).isButton){
      return InkWell(
        onTap: (){
          setState(() {
            for(int i = 0; i < ref.watch(taskDataProvider).chosenTaskIdList.length; i++){
              int targetId = ref.watch(taskDataProvider).chosenTaskIdList.elementAt(i);
              TaskDatabaseHelper().unDisplay(targetId);
            }
          });
            final list = ref.read(taskDataProvider).taskDataList;
            final newList = [...list];
            ref.read(taskDataProvider.notifier).state =
                TaskData(taskDataList: newList);
              ref.read(taskDataProvider).isRenewed = true;
        },
        child: Container(
          width:SizeConfig.blockSizeHorizontal! *100,
          height:SizeConfig.blockSizeVertical! *10,
          color: Colors.pinkAccent,
          child:  Row(
            children:[
             const Spacer(),
             checkedListLength(15.0),
             const SizedBox(width:15),
             const Icon(Icons.delete,color:Colors.white),
             const Text("   Done!!!   ",style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold),),
             const Icon(Icons.delete,color:Colors.white),
             const Spacer(),
          ]),
          
          )
        
      );
    }else{
      return Container(height:0);
    }
  }


  Widget checkedListLength(fontSize) {
    final taskData = ref.watch(taskDataProvider);

      return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          padding: EdgeInsets.all(fontSize / 3),
          child: Text(
            (taskData.chosenTaskIdList.length ?? 0).toString(),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
                fontSize: fontSize),
          )
          );
  }


  Stream<String> getRemainingTimeStream(DateTime dtEnd) async* {
    while (dtEnd.isAfter(DateTime.now())) {
      Duration remainingTime = dtEnd.difference(DateTime.now());

      int days = remainingTime.inDays;
      int hours = (remainingTime.inHours % 24);
      int minutes = (remainingTime.inMinutes % 60);
      int seconds = (remainingTime.inSeconds % 60);

      yield '  あと$days日 $hours時間 $minutes分 $seconds秒  ';

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
              fontSize: SizeConfig.blockSizeHorizontal! * 4,
              fontWeight: FontWeight.w700,
              color: Colors.white,
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
    DateTime timeLimit = dtEnd;
    Duration difference = dtEnd.difference(DateTime.now());
    if (timeLimit.isBefore(DateTime.now()) == false) {
      if (difference >= const Duration(days: 4)) {
        return Container(
            decoration: BoxDecoration(
              color: Colors.blueGrey, // 背景色を指定
              borderRadius: BorderRadius.circular(15), // 角丸にする場合は設定
            ),
            child: Text(
              ("  あと${difference.inDays} 日  "),
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! * 4,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            )); // 日数の差を出力
      } else {
        return Container(
            decoration: BoxDecoration(
              color: Colors.red, // 背景色を指定
              borderRadius: BorderRadius.circular(15), // 角丸にする場合は設定
            ),
            child: repeatdaysLeft(dtEnd));
      }
    } else if (dtEnd.year == DateTime.now().year &&
        dtEnd.month == DateTime.now().month &&
        dtEnd.day == DateTime.now().day) {
      return Container(
          decoration: BoxDecoration(
            color: Colors.red, // 背景色を指定
            borderRadius: BorderRadius.circular(15), // 角丸にする場合は設定
          ),
          child: Text(
            ("  今日まで  "),
            style: TextStyle(
              fontSize: SizeConfig.blockSizeHorizontal! * 4,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          )); // 日数の差を出力
    } else {
      return Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0, 0, 0), // 背景色を指定
            borderRadius: BorderRadius.circular(15), // 角丸にする場合は設定
          ),
          child: Text(
            ' 期限切れ ',
            style: TextStyle(
              fontSize: SizeConfig.blockSizeHorizontal! * 4,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ));
    }
  }
  
  Widget dtEndTaskGroup(keyIndex) {
    ref.watch(taskDataProvider.notifier);
    ref.watch(taskDataProvider);
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int valueIndex) {
          return Container(
              child: dtEndTaskChild(keyIndex,valueIndex));
        },
        itemCount: widget
            .sortedData[widget.sortedData.keys.elementAt(keyIndex)]!
            .length,
      ),
    );
  }

 

  Widget dtEndTaskChild(keyIndex,valueIndex) {
    ref.watch(taskDataProvider.notifier);
    ref.watch(taskDataProvider);
    final taskData = ref.watch(taskDataProvider);
    DateTime dateEnd = widget.sortedData.keys.elementAt(keyIndex);
    List<Map<String, dynamic>> childData = widget.sortedData[dateEnd]!;
    Map<String, dynamic> targetData = childData.elementAt(valueIndex);


    bool isChosen = taskData.chosenTaskIdList.contains(targetData["id"]);

    return Row(children: [
      Text(truncateTimeEnd(targetData),
          style: TextStyle(
              fontSize: SizeConfig.blockSizeHorizontal! * 4,
              fontWeight: FontWeight.w700)),
      InkWell(
          onTap: () {
             bottomSheet(targetData);
          },
          child: Container(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // 影の色と透明度
                          spreadRadius: 1.5, // 影の広がり
                          blurRadius: 1, // ぼかしの強さ
                          offset: const Offset(0, 1), // 影の位置（横方向、縦方向）
                        ),
                      ]),
                  child: Row(children: [
                    CupertinoCheckbox(
                      value: isChosen, onChanged: (value) {
                        var chosenTaskIdList = ref.watch(taskDataProvider).chosenTaskIdList;
                      setState((){
                        isChosen = value ?? false;
                        if(chosenTaskIdList.contains(targetData["id"])){
                          ref.read(taskDataProvider).chosenTaskIdList.remove(targetData["id"]);
                        }else{
                          ref.read(taskDataProvider).chosenTaskIdList.add(targetData["id"]);
                        }
                      //ref.read(taskDataProvider.notifier).state;
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
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal! * 69,
                          child: Text(targetData["title"] ?? "(タイトルなし)",
                          style: TextStyle(
                            fontSize:
                                SizeConfig.blockSizeVertical! * 1.75,
                            color: Colors.grey,
                    )
                  )
                )
              ]),
            ])
          )
        )
      )
    ]);
  }




  void bottomSheet(targetData){
    TextEditingController summaryController =
        TextEditingController(text: targetData["summary"] ?? "");
    TextEditingController titleController =
        TextEditingController(text: targetData["title"] ?? "");
    TextEditingController descriptionController =
        TextEditingController(text: targetData["description"] ?? "");
    int id = targetData["id"];
            showModalBottomSheet(
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              context: context,
              builder: (BuildContext context) {
                return Container(
                    height: SizeConfig.blockSizeVertical! * 60,
                    margin: const EdgeInsets.only(top: 0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: 
                      Scrollbar(child:Column(
                        
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
                                    color:
                                        Colors.grey.withOpacity(0.5), // 影の色と透明度
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
                                      width:
                                          SizeConfig.blockSizeHorizontal! * 92,
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
                          SizedBox(
                            height: SizeConfig.blockSizeHorizontal! * 2,
                          ),

                          Padding(
                            padding: const EdgeInsets.only(left:15,right:15),
                            child:Column(
                            children:[Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "タスク名",
                              style: TextStyle(
                                  fontSize: SizeConfig.blockSizeHorizontal! * 4,
                                  fontWeight: FontWeight.normal,
                                  color:Colors.grey
                                  ),
                            ),
                          ),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextField(
                              controller: summaryController,
                              maxLines: 1,
                              decoration: const InputDecoration.collapsed(
                                hintText: "タスク名を入力…",
                                border: InputBorder.none,

                                hintStyle: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: TextStyle(
                                  fontSize: SizeConfig.blockSizeHorizontal! * 4,
                                  fontWeight: FontWeight.w400),
                                onSubmitted: (value){
                                TaskDatabaseHelper().updateSummary(id, value);
                                
                                final list = ref.read(taskDataProvider).taskDataList;
                                final newList = [...list];
                                ref.read(taskDataProvider.notifier).state =
                                    TaskData();
                                ref.read(taskDataProvider).isRenewed = true;
                                //Navigator.pop(context);
                              },
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeHorizontal! * 2,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "カテゴリ",
                              style: TextStyle(
                                  fontSize: SizeConfig.blockSizeHorizontal! * 4,
                                  fontWeight: FontWeight.normal,
                                  color:Colors.grey
                                  ),
                            ),
                          ),

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
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              style: TextStyle(
                                  fontSize: SizeConfig.blockSizeHorizontal! * 4,
                                  fontWeight: FontWeight.w400),
                              onSubmitted: (value){
                                TaskDatabaseHelper().updateTitle(id, value);
                                
                                final list = ref.read(taskDataProvider).taskDataList;
                                final newList = [...list];
                                ref.read(taskDataProvider.notifier).state =
                                    TaskData();
                                ref.read(taskDataProvider).isRenewed = true;
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeHorizontal! * 2,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "タスクの詳細",
                              style: TextStyle(
                                  fontSize: SizeConfig.blockSizeHorizontal! * 4,
                                  fontWeight: FontWeight.normal,
                                  color:Colors.grey
                                  ),
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeHorizontal! * 0.5,
                          ),
                              TextField(
                              textInputAction:
                                  TextInputAction.done,
                              onSubmitted: (value){
                                TaskDatabaseHelper().updateDescription(id, value);
                                
                                final list = ref.read(taskDataProvider).taskDataList;
                                final newList = [...list];
                                ref.read(taskDataProvider.notifier).state =
                                    TaskData();
                                ref.read(taskDataProvider).isRenewed = true;
                                Navigator.pop(context);
                              },
                              maxLines: 7,

                              controller: descriptionController,
                              style: TextStyle(
                                fontSize: SizeConfig
                                        .blockSizeHorizontal! *
                                    4,
                              ),
                              onChanged: (text) {
                                setState(() {
                                  isEditingText(
                                      descriptionController);
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: "(タスクの詳細やメモを入力…)",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(
                                    top: 0, left: 0, right: 4),
                                hintStyle: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          const SizedBox(height: 15),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical! * 70,
                    )
                  ])
                )    
              ],
            ),
          )      
        ));
      },
    );
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
}

  String getDayOfWeek(int weekday) {
    switch (weekday) {
      case 0:
        return '(月)';
      case 1:
        return '(火)';
      case 2:
        return '(水)';
      case 3:
        return '(木)';
      case 4:
        return '(金)';
      case 5:
        return '(土)';
      case 6:
        return '(日)';
      default:
        return '(不明な曜日)';
    }
  }