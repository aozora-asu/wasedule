import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/database_helper.dart';
import '../../components/organism/float_button.dart';
import '../../components/template/task_progress_indicator.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:expandable/expandable.dart';

import 'package:flutter_calandar_app/frontend/size_config.dart';
import '../../components/template/loading.dart';
import '../../components/template/add_data_card_button.dart';
import '../../components/template/brief_kanban.dart';
import '../../../data_manager.dart';

import '../../../colors.dart';
import '../../../../backend/temp_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskListByDtEnd extends ConsumerStatefulWidget  {
  Map<DateTime,List<Map<String,dynamic>>>sortedData = {};
 TaskListByDtEnd({
  required this.sortedData
 });
  @override
  _TaskListByDtEndState createState() => _TaskListByDtEndState();
}

class _TaskListByDtEndState extends ConsumerState<TaskListByDtEnd>  {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final taskData = ref.watch(taskDataProvider);
    Map<DateTime,List<Map<String,dynamic>>>sortedData = widget.sortedData;
    sortedData = taskData.sortDataByDtEnd(taskData.taskDataList);
    ref.watch(taskDataProvider.notifier);
    ref.watch(taskDataProvider);
      return Scrollbar(
       child:Container(
        child: ListView.builder(
         shrinkWrap: true,
         itemBuilder: (BuildContext context, int keyIndex){
          DateTime dateEnd = sortedData.keys.elementAt(keyIndex);
          String adjustedDtEnd = ("${dateEnd.month}月${dateEnd.day}日  ");
           return Container(
            width:SizeConfig.blockSizeHorizontal! *100,
            padding: const EdgeInsets.only(left:8.0,right:8.0,bottom:0.0,top:4.0),
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
               ExpandablePanel(
                header:Row(children:[
                 Column(
                 crossAxisAlignment:CrossAxisAlignment.start,
                 children:[
                  Row(children:[                  
                   Text(adjustedDtEnd,
                   style:TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal!*7,
                    fontWeight:FontWeight.w800
                    ),
                   ),
                  Text(" ${sortedData.values.elementAt(keyIndex).length}件",
                   style:TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal!*4.25,
                    fontWeight:FontWeight.w600,
                    color:Colors.grey
                    )
                  )
                  ]),
                  remainingTime(dateEnd)]),
                ]),
                
                collapsed: const SizedBox(),
                expanded: DtEndTaskGroup(keyIndex:keyIndex,sortedData: widget.sortedData,),
                controller:ExpandableController(initialExpanded:isLimitOver(dateEnd,sortedData,dateEnd))
                ),
                const Divider(
                  thickness: 2.5,
                  indent: 7,
                  endIndent: 7,
                )
          ])
         );
        },
       itemCount: sortedData.keys.length,
     ),
    )
   );
  }

  bool isLimitOver
   (DateTime dtEnd,
    Map<DateTime,List<Map<String,dynamic>>>sortedData,
    DateTime keyDateTime){
    DateTime timeLimit =dtEnd;
  
  switch(ref.watch(taskDataProvider).foldState){
    case 0:
      if (timeLimit.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return false;
      }else{
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
    DateTime timeLimit =dtEnd;
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
    } else if(dtEnd.year == DateTime.now().year && dtEnd.month == DateTime.now().month && dtEnd.day == DateTime.now().day) {
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
        )
      );
    }
  }
}



class DtEndTaskGroup extends ConsumerStatefulWidget {
  final int keyIndex;
  final Map<DateTime,List<Map<String,dynamic>>>sortedData;

  DtEndTaskGroup({
   required this.keyIndex,
   required this.sortedData
  });

  @override
  _DtEndTaskGroupState createState() => _DtEndTaskGroupState();
}

class _DtEndTaskGroupState extends ConsumerState<DtEndTaskGroup> {
  @override
  Widget build(BuildContext context) {
    ref.watch(taskDataProvider.notifier);
    ref.watch(taskDataProvider);
    //final taskData = ref.watch(taskDataProvider);
    //widget.sortedData = taskData.sortDataByDtEnd(taskData.taskDataList);
    return Container(
      //height: SizeConfig.blockSizeVertical!*12*widget.sortedData[widget.sortedData.keys.elementAt(widget.keyIndex)]!.length,
      width:SizeConfig.blockSizeHorizontal!*100,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int valueIndex){
          return Container(
              child:
              DtEndTaskChild(keyIndex:widget.keyIndex,valueIndex:valueIndex,sortedData:widget.sortedData,)
         );
        },
        itemCount: widget.sortedData[widget.sortedData.keys.elementAt(widget.keyIndex)]!.length,
      ),
    );
   }
  }



  class DtEndTaskChild extends ConsumerStatefulWidget {
  final int keyIndex;
  final int valueIndex;
  final Map<DateTime,List<Map<String,dynamic>>>sortedData;

  DtEndTaskChild({
   required this.keyIndex,
   required this.valueIndex,
   required this.sortedData
  });

  @override
  _DtEndTaskChildState createState() => _DtEndTaskChildState();
}

class _DtEndTaskChildState extends ConsumerState<DtEndTaskChild> {
  
  @override
  Widget build(BuildContext context) {
    ref.watch(taskDataProvider.notifier);
    ref.watch(taskDataProvider);
    final taskData = ref.watch(taskDataProvider);
          DateTime dateEnd = widget.sortedData.keys.elementAt(widget.keyIndex);
          List<Map<String,dynamic>> childData =  widget.sortedData[dateEnd]!;
          Map<String,dynamic> targetData = childData.elementAt(widget.valueIndex);
          TextEditingController descriptionController = 
            TextEditingController(text: targetData["descriptionController"] ?? "");

          return Row(children:[
              Text(truncateTimeEnd(targetData),
               style:TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal!*4,
                fontWeight:FontWeight.w700
                )
              ),
              InkWell(
      onTap: () {
        showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          builder: (BuildContext context) {
            return Container(
              margin: const EdgeInsets.only(top: 64),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
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
                          Container(
                              width: SizeConfig.blockSizeHorizontal! * 92,
                              child: Row(
                                children: [
                                  Container(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            SizeConfig.blockSizeHorizontal! *
                                                73.5),
                                    child: Text(
                                      targetData["summary"] ?? "(詳細なし)",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal! *
                                                  5,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  Text(
                                    "  の詳細",
                                    style: TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal! * 5,
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "   タスク名",
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal! * 4,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeHorizontal! * 1,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "   ${targetData["summary"] ?? ""}",
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal! * 4,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeHorizontal! * 2,
                  ),


                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "   カテゴリ",
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal! * 4,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeHorizontal! * 1,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "   ${targetData["title"] ?? "(カテゴリなし)"}",
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal! * 4,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeHorizontal! * 2,
                  ),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "   タスクの詳細",
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal! * 4,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeHorizontal! * 0.5,
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeHorizontal! * 17,
                    //width: SizeConfig.blockSizeHorizontal! * 93,
                    child: Row(
                      children: [
                        Container(
                          //width: SizeConfig.blockSizeHorizontal! *90,
                          height: SizeConfig.blockSizeHorizontal! * 17,
                          alignment: Alignment.topLeft,
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: SizeConfig.blockSizeHorizontal! * 2,
                              ),
                              SingleChildScrollView(
                                child: Container(
                                  margin: const EdgeInsets.only(top: 0),
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        SizeConfig.blockSizeHorizontal! * 97,
                                  ),
                                  //width: SizeConfig.blockSizeHorizontal! * 90,
                                  alignment: Alignment.topLeft,
                                  height: SizeConfig.blockSizeHorizontal! * 17,
                                  child: TextField(
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (inputValue) {
                                      //userInput = inputValue;
                                      // widget.databaseHelper.updateDescription(
                                      //     widget.index, userInput);
                                    },
                                    maxLines: 7,
                                    textAlign: TextAlign.start,
                                    controller: descriptionController,
                                    style: TextStyle(
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal! * 4,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: "タスクの詳細やメモを入力…",
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.only(
                                          top: 0, left: 4, right: 4),
                                      hintStyle: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "   タスクの優先度設定",
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal! * 4,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  PriorityTabBar(),
                ],
              ),
            );
          },
        );
      },
           child: Container(
                constraints: BoxConstraints(
                maxWidth:SizeConfig.blockSizeHorizontal!*85,
                  ),
               padding: const EdgeInsets.only(top:8.0,bottom:8.0,left:8.0),
                child:Container(
                decoration: BoxDecoration(
                 color:Colors.white,
                 borderRadius:const BorderRadius.all(Radius.circular(15)),
                 boxShadow: [
                  BoxShadow(
                   color: Colors.black.withOpacity(0.2), // 影の色と透明度
                   spreadRadius: 2, // 影の広がり
                   blurRadius: 3, // ぼかしの強さ
                   offset: const Offset(0, 2), // 影の位置（横方向、縦方向）
                  ),
                 ]
                ),
                width:SizeConfig.blockSizeHorizontal!*85,
                child:Row(children:[
                 CupertinoCheckbox(
                  value:false,
                  onChanged: (value){

                 }),

                 Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children:[
                SizedBox(
                width: SizeConfig.blockSizeHorizontal!* 70,
                child:Text(targetData["summary"] ?? "(詳細なし)",
                  style:TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal!*4.5,
                    fontWeight:FontWeight.w700
                  ))
                ),
                SizedBox(
                width: SizeConfig.blockSizeHorizontal!* 70,
                child:Text(targetData["title"] ?? "(タイトルなし)",
                  style:TextStyle(
                    fontSize: SizeConfig.blockSizeVertical!*1.75,
                    color: Colors.grey,
                   //fontWeight:FontWeight.w700
                )
               )
              )
              ]
             ),
            ])
          )
        ))

      ]);
    }
    String truncateTimeEnd(targetData){
      String hour = DateTime.fromMillisecondsSinceEpoch(targetData["dtEnd"]).hour.toString();
      String minute = DateTime.fromMillisecondsSinceEpoch(targetData["dtEnd"]).minute.toString();
    
      String formattedhour = hour.padLeft(2, '0');
      String formattedminute = minute.padLeft(2, '0');

      return formattedhour+":"+formattedminute;
    }
  }

//詳細のポップアップ///////////////////////////////////////////////////////////////////////////////////
class InformationAutoDismissiblePopup extends StatefulWidget {
  late TextEditingController controller;
  late int index;
  String _userInput2 = '';
  late String text;
  TaskDatabaseHelper databaseHelper = TaskDatabaseHelper();
  late String titleName;
  late String summary;

  InformationAutoDismissiblePopup(
      {
      required this.text,
      required this.titleName,
      required this.summary});

  @override
  InformationAutoDismissiblePopupState createState() =>
      InformationAutoDismissiblePopupState();
}

class InformationAutoDismissiblePopupState
    extends State<InformationAutoDismissiblePopup> {
  @override
  void initState() {
    super.initState();
    widget.controller = TextEditingController(text: widget.text);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return InkWell(
      child: SizedBox(
        width: SizeConfig.blockSizeHorizontal! * 8,
        height: SizeConfig.blockSizeHorizontal! * 8,
        child: Icon(
          Icons.more_horiz,
          color: Colors.blueGrey,
          size: SizeConfig.blockSizeHorizontal! * 8,
        ),
      ),
    );
  }
}