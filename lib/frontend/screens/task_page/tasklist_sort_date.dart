import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/sharepreference.dart';
import 'dart:async';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';

import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/screens/common/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/add_data_card_button.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_modal_sheet.dart';

import 'task_data_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TaskListByDtEnd extends ConsumerStatefulWidget {
  Map<DateTime, List<Map<String, dynamic>>> sortedData = {};
  late Function(ScrollController) onScroll;

  TaskListByDtEnd({
    super.key,
    required this.sortedData,
    required this.onScroll
  });

  @override
  _TaskListByDtEndState createState() => _TaskListByDtEndState();
}

class _TaskListByDtEndState extends ConsumerState<TaskListByDtEnd> {
  late int _range;
  final DateTime now = DateTime.now();
  late ScrollController _taskScrollController;
  late ScrollController _calendarScrollController;
  List<GlobalKey> _keys = [];
  Map<int,double> _heights = {};
  bool _isVisible = true;

  double selectorWidth  = SizeConfig.blockSizeHorizontal! *75;
  double indicatorWidth = 45;
  String indicatorTextYear = "";
  String indicatorTextMonth = "";

  @override
  void initState() {
    super.initState();
  
    _setMaxday();

    _taskScrollController = ScrollController();
    _calendarScrollController = ScrollController();
    _calendarScrollController.addListener(_calendarScrollListener);
    // コントローラ1のスクロールをコントローラ2に反映
    // _calendarScrollController.addListener(() {
    //   if (_calendarScrollController.offset != _taskScrollController.offset) {
    //     _taskScrollController.jumpTo(_calendarScrollController.offset *2);
    //   }
    // });

    // // コントローラ2のスクロールをコントローラ1に反映
    // _taskScrollController.addListener(() {
    //   if (_taskScrollController.offset != _calendarScrollController.offset) {
    //     _calendarScrollController.jumpTo(_taskScrollController.offset);
    //   }
    // });

    _taskScrollController.addListener(() {

      if (_taskScrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        // 下方向にスクロールしたとき
        if (_isVisible) {
          setState(() {
            _isVisible = false;
          });
        }
      } else if (_taskScrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        // 上方向にスクロールしたとき
        if (!_isVisible) {
          setState(() {
            _isVisible = true;
          });
        }
      }
      widget.onScroll(_taskScrollController);
    });

    // 各アイテムに対して GlobalKey を作成
    _keys = List.generate(_range, (index) => GlobalKey());


    WidgetsBinding.instance.addPostFrameCallback(
      (_){
        jumpToIndex(_getTodayIndex());
      }
    );

    String yearText =DateFormat("yyyy").format(findLastSunday());
    String monthText = DateFormat("M").format(findLastSunday());
    indicatorTextYear = yearText;
    indicatorTextMonth = monthText;

  }

  // 各要素の高さを取得
  void _getAllHeights() {
    int i = 0;
    for (var key in _keys) {
      final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        _heights[i] = renderBox.size.height;
      }
      i ++;
    }
  }

  DateTime _getDateFromIndex(int index) {
    final DateTime startDate = findLastSunday();
    return startDate.add(Duration(days: index));
  }

  int _getTodayIndex() {
    final DateTime lastSunday = findLastSunday();
    final DateTime today = DateTime(now.year,now.month,now.day,0,0,0,0,0);
    Duration fromSunday = today.difference(lastSunday);
    return fromSunday.inDays;
  }

  DateTime findLastSunday() {
    DateTime today = DateTime(now.year,now.month,now.day,0,0,0,0,0);
    // 今日の曜日 (0: Sunday, 1: Monday, ..., 6: Saturday)
    int weekday = today.weekday;
    // DateTimeのweekdayでは、Sundayが7 (週の最後)なので、扱いを調整
    int daysToSubtract = (weekday % 7); // 日曜日の分の日数を引く
    return today.subtract(Duration(days: daysToSubtract));
  }

  void _calendarScrollListener() {
    setState((){});
  }

  void _setMaxday(){
    List<DateTime> dateList = widget.sortedData.keys.toList();
    int maxDayFromToday = 0;
    for(var targetDay in dateList){
      if(targetDay.difference(findLastSunday()).inDays > maxDayFromToday){
        maxDayFromToday = targetDay.difference(findLastSunday()).inDays;
      }
    }
    _range = maxDayFromToday + 30;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final taskData = ref.watch(taskDataProvider);
    Map<DateTime, List<Map<String, dynamic>>> sortedData = widget.sortedData;
    sortedData = taskData.sortDataByDtEnd(taskData.taskDataList);
    ref.watch(taskDataProvider.notifier);
    ref.watch(taskDataProvider);
    bool isShowDayWithoutTask = 
      SharepreferenceHandler().getValue(SharepreferenceKeys.isShowDayWithoutTask);
    bool isShowTaskCalendarLine = 
      SharepreferenceHandler().getValue(SharepreferenceKeys.isShowTaskCalendarLine);

      _setMaxday();

    return Scaffold(
     backgroundColor: BACKGROUND_COLOR,
     body: Stack(children: [
      Column(children: [
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            controller: _taskScrollController,
            primary: false,
            itemBuilder: (BuildContext context, int index) {
              DateTime date = _getDateFromIndex(index);
              Widget child;

              if(sortedData.containsKey(date)){
                child = dailyViewWithTasks(context, date);
              }else{
                child = isShowDayWithoutTask 
                  ? dailyViewWithoutTasks(date)
                  : const SizedBox();
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                _getAllHeights();
              });

              return Container(
                key:_keys[index],
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: BACKGROUND_COLOR,
                  // boxShadow: [
                  //   if(sortedData.containsKey(date) || isShowDayWithoutTask )
                  //     BoxShadow(
                  //       color: Colors.black.withOpacity(0.1),
                  //       spreadRadius: 1,
                  //       blurRadius: 1,
                  //       offset: const Offset(0, 0),
                  //     ),
                  // ],
                ),
                margin: EdgeInsets.symmetric(
                  horizontal:5,
                  vertical:
                    sortedData.containsKey(date) || isShowDayWithoutTask 
                      ? 2 : 0),
                child: child);

            },
            itemCount: _range,
          ),
        )
      ]),
      executeDeleteButton(),
     ]),
     floatingActionButton: AnimatedOpacity(
            opacity: _isVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 600),
            child:Container(
              margin: EdgeInsets.only(
                bottom: _isVisible ? 0 : 1000),
                child: Row(children:[
                  const Spacer(),
                  if(isShowTaskCalendarLine)
                    dateSelector(),
                  const SizedBox(width: 10),
                  AddDataCardButton(setosute: setState),          
                ])  
          )
        )

    );
  }

  Widget dailyViewWithTasks(BuildContext context, DateTime date){
    final taskData = ref.watch(taskDataProvider);
    Map<DateTime, List<Map<String, dynamic>>> sortedData = widget.sortedData;
    sortedData = taskData.sortDataByDtEnd(taskData.taskDataList);
    DateTime dateEnd = DateTime.fromMillisecondsSinceEpoch(
        sortedData[date]!.first["dtEnd"]);
    String adjustedDtEnd =
        ("${dateEnd.month}月${dateEnd.day}日 (${"日月火水木金土日"[dateEnd.weekday % 7]}) ");
      return Container(
          padding: const EdgeInsets.only(
              left: 4.0, right: 0, bottom: 13.0, top: 4.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(children:[
                    Row(children: [
                      const SizedBox(width: 0),
                      Text(
                        adjustedDtEnd,
                        style:const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: BLUEGREY),
                      ),
                      const Spacer(),
                      remainingTime(dateEnd),
                      const SizedBox(width: 10)
                    ]),
                    dtEndTaskGroup(
                      sortedData.keys.toList().indexOf(date),
                    ),
                ])
              ]));
  }

  Widget dailyViewWithoutTasks(DateTime date){
    String adjustedDtEnd = 
      ("${date.month}月${date.day}日 (${"日月火水木金土日"[date.weekday % 7]}) ");

    return Container(
        padding: const EdgeInsets.only(
            left: 4.0, right: 0, bottom: 13.0, top: 4.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(children: [
                    Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const SizedBox(width: 0),
                        Text(
                          adjustedDtEnd,
                          style:const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: BLUEGREY),
                        ),
                      ]),
                      GestureDetector(
                        onTap: () async{
                          final inputForm = ref.read(inputFormProvider);
                          inputForm.clearContents();
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return TaskInputForm(
                                initDate: date,
                                setosute: setState);
                          });
                          setState(() {
                            _setMaxday();
                          });
                        },
                        child:Container(
                          padding:const EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                          margin: const EdgeInsets.only(top: 5),
                          child:const Row(children:[
                            Icon(
                              Icons.add_circle_outline_outlined,
                              color:Colors.grey,
                              size: 20),
                          SizedBox(width: 5),
                          Text("課題の追加",
                            style: TextStyle(fontWeight: FontWeight.bold,color:Colors.grey),)
                        ])
                      )),
                    ]),
                  ]),
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
            height: SizeConfig.blockSizeVertical! * 7,
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
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: FORGROUND_COLOR,
            ),
          );
        } else {
          return const SizedBox();
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
    double fontSize = 13;
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
    ScrollController _controller = ScrollController();
    ref.watch(taskDataProvider.notifier);
    ref.watch(taskDataProvider);
    return  ListView.separated(
        shrinkWrap: true,
        primary: false,
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int valueIndex) {
          return Container(child: dtEndTaskChild(keyIndex, valueIndex));
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: 2);
        },
        itemCount: widget
            .sortedData[widget.sortedData.keys.elementAt(keyIndex)]!.length,
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
          width: 35,
          child: 
            Text(
              DateFormat("HH:mm").format(
                  DateTime.fromMillisecondsSinceEpoch(targetData["dtEnd"])),
              textAlign: TextAlign.center,
              style:const TextStyle(
                  fontSize: 12.5,

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
                    padding: const EdgeInsets.symmetric(vertical: 7,horizontal: 3),
                    decoration: BoxDecoration(
                      color: FORGROUND_COLOR,
                      borderRadius: radius,
                    ),
                    child: Column(children: [
                      Row(children: [
                        Transform.scale(
                          scale: 1.1,
                          child: 
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
                            })
                          ),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    child: Text(
                                        targetData["summary"] ?? "(詳細なし)",
                                        style:const TextStyle(
                                              fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: BLACK))),
                                SizedBox(
                                    child:
                                        Text(targetData["title"] ?? "(タイトルなし)",
                                            style:const TextStyle(
                                              fontSize: 12.5,
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
        Spacer(),
        Text("💬下書きあり",
            style: TextStyle(
                color: BLUEGREY,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
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



  Widget dateSelector(){
    String _indiTextYear = indicatorTextYear;
    String _indiTextMonth = indicatorTextMonth;

    return Container(
      width: selectorWidth,
      height: 55,
      padding:const EdgeInsets.symmetric(vertical: 0,horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: PALE_MAIN_COLOR,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ]
      ),
      child: Row(children:[
        Container(
          width: indicatorWidth - 15,
          alignment: Alignment.centerLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
          children:[
            Text(_indiTextYear,
              style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:11)
            ),
            Text(_indiTextMonth,
              style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:18),
            ),
          ])
        ),
        Expanded(child:
          Container(
            margin:const EdgeInsets.symmetric(horizontal: 0,vertical: 5),
            width: selectorWidth - indicatorWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color:  BACKGROUND_COLOR,
              border: Border.all(width: 0.15)
            ),
            child:ListView.separated(
                controller: _calendarScrollController,
                physics: const PageScrollPhysics(),
                primary: false,
                itemBuilder:(context,index){
                  DateTime targetSunday = findLastSunday().add(Duration(days: (index * 7))); 
                  String yearText =DateFormat("yyyy").format(targetSunday.subtract(const Duration(days:7)));
                  String monthText = DateFormat("M").format(targetSunday.subtract(const Duration(days:7)));
                  indicatorTextYear = yearText;
                  indicatorTextMonth = monthText;

                  return weekCalendarLine(targetSunday, index * 7);
                },
                separatorBuilder: (context,index){
                  return const SizedBox();
                },
                scrollDirection: Axis.horizontal,
                itemCount: _range,
              )
            )
          ),
          const SizedBox(width: 5),
      ])
    );
  }

  Widget weekCalendarLine(DateTime startDay,int startIndex){
    return SizedBox(
      width: selectorWidth - indicatorWidth - 0.3,
      child:ListView.builder(
        itemBuilder: (context,index){
          int dayIndex = startIndex + index;
          DateTime targetDate = startDay.add(Duration(days:index));
          return dailyCalendarObject(targetDate, dayIndex);
        },
        itemCount: 7,
        shrinkWrap: true,
        physics:const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
      )
    );
  }

  Widget dailyCalendarObject(DateTime date,int index){
    double widthParDay = (selectorWidth - indicatorWidth) / 7;
    List dailyData = widget.sortedData[date] ?? [];
    Color bgColor = Colors.transparent;
    Color weekDayColor = Colors.grey;
    Color dayColor = Colors.black;

    if(date == DateTime(now.year,now.month,now.day,0,0,0,0,0)){
      bgColor = MAIN_COLOR;
      weekDayColor = Colors.white;
      dayColor = Colors.white;
    }else if(date.weekday == 6){
      weekDayColor = Colors.blue;
    }else if(date.weekday == 7){
      weekDayColor = Colors.red;
    }

    return GestureDetector(
      onTap:(){
        jumpToIndex(index);
      },
      child:Stack(
        alignment:const Alignment(0.8,-1),
        children:[
          Container(
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle
            ),
            width: widthParDay,
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Text(DateFormat("E","ja_jp").format(date),
                style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold,color: weekDayColor)),
              Text(date.day.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: dayColor)),
            ]),
          ),
          lengthBadge(dailyData.length,10.0,true)
      ])
    );
  }

  void jumpToIndex(index){
    double heightSum = 0;
    bool isShowDayWithoutTask =  
      SharepreferenceHandler().getValue(SharepreferenceKeys.isShowDayWithoutTask);
    for(int i = 0; i < index; i++){
      heightSum += _heights[i] ?? (isShowDayWithoutTask ? 80 : 0);
    }
    
    _taskScrollController.animateTo(
      heightSum,
      duration:const Duration(milliseconds: 700),
      curve: Curves.decelerate);
    
  }

  @override
  void dispose() {
    _calendarScrollController.dispose();
    _taskScrollController.dispose();
    super.dispose();
  }

}
