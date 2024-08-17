import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calandar_app/backend/DB/handler/arbeit_db_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_data_manager.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/screens/common/plain_appbar.dart';
import 'package:intl/intl.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_data_manager.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class ArbeitCalculator{
  int returnCorrectedWage(tagData, targetKey ,ref) {
    bool found = false;
    int result = 0;

    for (var data in ref.read(calendarDataProvider).arbeitData) {
      String month = data["month"];
      int tagId = data["tagId"];
      int wage = data["wage"];

      if (month == targetKey && tagId == tagData["id"]) {
        found = true;
        result += wage;
      }
    }

    if (!found) {
      result += (culculateWage(
              monthlyWorkTimeSumWithAdditionalWorkTime(tagData, targetKey ,ref),
              tagData["wage"]) +
          monthlyFeeSum(tagData, targetKey ,ref));
    }
    return result;
  }

  Duration monthlyWorkTimeSumOfAllTags(targetKey,ref){
    final tagData = ref.watch(calendarDataProvider).tagData;
    Duration result = Duration.zero;
    for(int i = 0; i < tagData.length; i++){
      if(tagData.elementAt(i)["isBeit"] == 1){
        result += monthlyWorkTimeSum(tagData.elementAt(i),targetKey,ref);
      }
    }
    return result;
  }

  Duration monthlyWorkTimeSum(tagData, targetKey ,ref) {
    Map sortedDataByMonth = ref.watch(calendarDataProvider).sortedDataByMonth;
    Duration result = Duration.zero;
    if (sortedDataByMonth[targetKey] != null) {
      for (int i = 0; i < sortedDataByMonth[targetKey].length; i++) {
        for (int ind = 0;
            ind < sortedDataByMonth[targetKey].values.elementAt(i).length;
            ind++) {
          String? tagId = sortedDataByMonth[targetKey]
              .values
              .elementAt(i)
              .elementAt(ind)["tagID"] ?? "";
          Map targetScheduleData =
              sortedDataByMonth[targetKey].values.elementAt(i).elementAt(ind);

          if (tagId == tagData["tagID"].toString()) {
            Duration start =
                parseTimeToDuration(targetScheduleData["startTime"]);
            Duration end = parseTimeToDuration(targetScheduleData["endTime"]);
            Duration newDuration = end;
            newDuration -= start;

            if (const Duration(hours: 6) < newDuration &&
                newDuration <= const Duration(hours: 8)) {
              newDuration -= const Duration(minutes: 45);
            } else if (newDuration > const Duration(hours: 8)) {
              newDuration -= const Duration(hours: 1);
            }

            result += newDuration;
          }
        }
      }
    }
    return result;
  }

  Duration monthlyWorkTimeSumWithAdditionalWorkTime(tagData, targetKey ,ref) {
    Map sortedDataByMonth = ref.watch(calendarDataProvider).sortedDataByMonth;

    Duration result = Duration.zero;
    if (sortedDataByMonth[targetKey] != null) {
      for (int i = 0; i < sortedDataByMonth[targetKey].length; i++) {
        for (int ind = 0;
            ind < sortedDataByMonth[targetKey].values.elementAt(i).length;
            ind++) {
          String? tagId = sortedDataByMonth[targetKey]
              .values
              .elementAt(i)
              .elementAt(ind)["tagID"] ?? "";
          Map targetScheduleData =
              sortedDataByMonth[targetKey].values.elementAt(i).elementAt(ind);

          if (tagId == tagData["tagID"].toString()) {
            Duration start =
                parseTimeToDuration(targetScheduleData["startTime"]);
            Duration end = parseTimeToDuration(targetScheduleData["endTime"]);
            Duration newDuration = end;
            newDuration -= start;

            //休憩時間の減算(6時間以上で45分、8時間以上で60分)
            if (const Duration(hours: 6) < newDuration &&
                newDuration <= const Duration(hours: 8)) {
              newDuration -= const Duration(minutes: 45);
            } else if (newDuration > const Duration(hours: 8)) {
              newDuration -= const Duration(hours: 1);
            }

            //時間外労働分の加算(8時間を超えた分は1.25倍)
            if (newDuration > const Duration(hours: 8)) {
              Duration additional = newDuration - const Duration(hours: 8);
              newDuration -= additional;
              newDuration += additional * 1.25;
            }

            //深夜労働分の加算(夜10時以降、朝5時以前は1.25倍)
            if (start <= const Duration(hours: 22) &&
                const Duration(hours: 22) <= end) {
              Duration additional = end - const Duration(hours: 22);
              newDuration -= additional;
              newDuration += additional * 1.25;
            } else if (const Duration(hours: 22) <= start &&
                const Duration(hours: 22) <= end) {
              Duration additional = newDuration;
              newDuration = additional * 1.25;
            }

            if (start <= const Duration(hours: 5) &&
                const Duration(hours: 5) <= end) {
              Duration additional = const Duration(hours: 5) - start;
              newDuration -= additional;
              newDuration += additional * 1.25;
            } else if (start <= const Duration(hours: 5) &&
                end <= const Duration(hours: 5)) {
              Duration additional = newDuration;
              newDuration = additional * 1.25;
            }

            result += newDuration;
          }
        }
      }
    } else {}
    return result;
  }

  Duration parseTimeToDuration(String timeString) {
    List<String> parts = timeString.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    return Duration(hours: hours, minutes: minutes);
  }

  int monthlyFeeSum(tagData, targetKey ,ref) {
    Map sortedDataByMonth = ref.watch(calendarDataProvider).sortedDataByMonth;
    int result = 0;
    if (sortedDataByMonth[targetKey] != null) {
      for (int i = 0; i < sortedDataByMonth[targetKey].length; i++) {
        for (int ind = 0;
            ind < sortedDataByMonth[targetKey].values.elementAt(i).length;
            ind++) {
          String? tagId = sortedDataByMonth[targetKey]
              .values
              .elementAt(i)
              .elementAt(ind)["tagID"] ?? "";

          if (tagId == tagData["tagID"].toString()) {
            int f = tagData["fee"];
            result += f * 2;
          }
        }
      }
    } else {}

    return result;
  }

  int culculateWage(Duration duration, int multiplier) {
    int wage = ((duration.inMinutes * multiplier) / 60).round();
    return wage;
  }

  Duration yearlyWorkTimeSum(tagData, targetKey ,ref) {
    Map sortedDataByMonth = ref.watch(calendarDataProvider).sortedDataByMonth;
    Duration result = Duration.zero;
    String year = targetKey.substring(0, 4);
    List<String> targetKeys = [
      "$year-01",
      "$year-02",
      "$year-03",
      "$year-04",
      "$year-05",
      "$year-06",
      "$year-07",
      "$year-08",
      "$year-09",
      "$year-10",
      "$year-11",
      "$year-12",
    ];

    for (int i = 0; i < targetKeys.length; i++) {
      if (sortedDataByMonth[targetKeys.elementAt(i)] != null) {
        result += monthlyWorkTimeSum(tagData, targetKeys.elementAt(i) ,ref);
      }
    }

    return result;
  }

  int yearlyWageSumWithAdditionalWorkTime(targetKey ,ref) {
    List tagData = ref.watch(calendarDataProvider).tagData;
    Map sortedDataByMonth = ref.watch(calendarDataProvider).sortedDataByMonth;
    int result = 0;
    String year = targetKey.substring(0, 4);
    List<String> targetKeys = [
      "$year-01",
      "$year-02",
      "$year-03",
      "$year-04",
      "$year-05",
      "$year-06",
      "$year-07",
      "$year-08",
      "$year-09",
      "$year-10",
      "$year-11",
      "$year-12",
    ];
    for (int i = 0; i < tagData.length; i++) {
      if (tagData.elementAt(i)["isBeit"] == 1) {
        for (int ind = 0; ind < targetKeys.length; ind++) {
          if (sortedDataByMonth[targetKeys.elementAt(ind)] != null) {
            result += returnCorrectedWage(
                tagData.elementAt(i), targetKeys.elementAt(ind) ,ref);
          }
        }
      }
    }
    return result;
  }

  int yearlyFeeSum(tagData, targetKey ,ref) {
    Map sortedDataByMonth = ref.watch(calendarDataProvider).sortedDataByMonth;
    int result = 0;
    String year = targetKey.substring(0, 4);
    List<String> targetKeys = [
      "$year-01",
      "$year-02",
      "$year-03",
      "$year-04",
      "$year-05",
      "$year-06",
      "$year-07",
      "$year-08",
      "$year-09",
      "$year-10",
      "$year-11",
      "$year-12",
    ];

    for (int i = 0; i < targetKeys.length; i++) {
      if (sortedDataByMonth[targetKeys.elementAt(i)] != null) {
        result += monthlyFeeSum(tagData, targetKeys.elementAt(i) ,ref);
      }
    }

    return result;
  }

  int yearlyFeeSumOfAllTags(targetKey ,ref) {
    List tagData = ref.watch(calendarDataProvider).tagData;
    Map sortedDataByMonth = ref.watch(calendarDataProvider).sortedDataByMonth;

    int result = 0;
    String year = targetKey.substring(0, 4);
    List<String> targetKeys = [
      "$year-01",
      "$year-02",
      "$year-03",
      "$year-04",
      "$year-05",
      "$year-06",
      "$year-07",
      "$year-08",
      "$year-09",
      "$year-10",
      "$year-11",
      "$year-12",
    ];
    for (int i = 0; i < tagData.length; i++) {
      if (tagData.elementAt(i)["isBeit"] == 1) {
        for (int ind = 0; ind < targetKeys.length; ind++) {
          if (sortedDataByMonth[targetKeys.elementAt(ind)] != null) {
            result +=
                monthlyFeeSum(tagData.elementAt(i), targetKeys.elementAt(i) ,ref);
          }
        }
      }
    }
    return result;
  }

  int monthlyFeeSumOfAllTags(targetKey ,ref) {
    List tagData = ref.watch(calendarDataProvider).tagData;
    Map sortedDataByMonth = ref.watch(calendarDataProvider).sortedDataByMonth;

    int result = 0;

    for (int i = 0; i < tagData.length; i++) {
      if (tagData.elementAt(i)["isBeit"] == 1) {
        if (sortedDataByMonth[targetKey] != null) {
          result += monthlyFeeSum(tagData.elementAt(i), targetKey ,ref);
        }
      }
    }
    return result;
  }

  int numberOfValidMonthNullsafe(targetKey ,ref) {
    Map sortedDataByMonth = ref.watch(calendarDataProvider).sortedDataByMonth;
    int result = 0;
    String year = targetKey.substring(0, 4);
    List<String> targetKeys = [
      "$year-01",
      "$year-02",
      "$year-03",
      "$year-04",
      "$year-05",
      "$year-06",
      "$year-07",
      "$year-08",
      "$year-09",
      "$year-10",
      "$year-11",
      "$year-12",
    ];

    for (int i = 0; i < targetKeys.length; i++) {
      if (sortedDataByMonth[targetKeys.elementAt(i)] != null) {
        result += 1;
      }
    }

    if (result == 0) {
      result = 1;
    }

    return result;
  }

  int numberOfValidMonth(targetKey ,ref) {
    Map sortedDataByMonth = ref.watch(calendarDataProvider).sortedDataByMonth;
    int result = 0;
    String year = targetKey.substring(0, 4);
    List<String> targetKeys = [
      "$year-01",
      "$year-02",
      "$year-03",
      "$year-04",
      "$year-05",
      "$year-06",
      "$year-07",
      "$year-08",
      "$year-09",
      "$year-10",
      "$year-11",
      "$year-12",
    ];

    for (int i = 0; i < targetKeys.length; i++) {
      if (sortedDataByMonth[targetKeys.elementAt(i)] != null) {
        result += 1;
      }
    }

    return result;
  }

  int monthlyWageSum(targetKey ,ref) {
    List tagData = ref.watch(calendarDataProvider).tagData;
    int result = 0;
    String modifiedKey =
        targetKey.substring(0, 4) + "-" + targetKey.substring(5, 7);
    for (int i = 0; i < tagData.length; i++) {
      if (tagData.elementAt(i)["isBeit"] == 1) {
        result += culculateWage(
            monthlyWorkTimeSumWithAdditionalWorkTime(
                tagData.elementAt(i), modifiedKey ,ref),
            tagData.elementAt(i)["wage"]);
      }
    }
    return result;
  }

  String formatNumberWithComma(int number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
}


class ArbeitStatsPage extends ConsumerStatefulWidget {
  String targetMonth;
  bool? isAppbar;

  ArbeitStatsPage({super.key, 
    required this.targetMonth,
    this.isAppbar});

  @override
  ArbeitStatsPageState createState() => ArbeitStatsPageState();
}

class ArbeitStatsPageState extends ConsumerState<ArbeitStatsPage> {
  Color charColor = const Color.fromARGB(255, 200, 200, 200);
  Color charColorLight = const Color.fromARGB(255, 150, 150, 150);
  late int includeFee;

  @override
  void initState() {
    super.initState();
    includeFee = 1;
  }

  @override
  Widget build(BuildContext context) {
    ref.read(calendarDataProvider).sortDataByMonth();
    SizeConfig().init(context);
    Map sortedDataByMonth = ref.watch(calendarDataProvider).sortedDataByMonth;
    String year = widget.targetMonth.substring(0, 4);
    String month = widget.targetMonth.substring(5, 7);
    String targetKey = "$year-$month";
    Widget estimatedMonthlyIncome = Container();
    bool isAppBar = widget.isAppbar ?? false;

    if (includeFee == 1) {
      estimatedMonthlyIncome = Text(
          "${ArbeitCalculator().formatNumberWithComma(
            ArbeitCalculator().monthlyWageSum(widget.targetMonth,ref) +
                  ArbeitCalculator().monthlyFeeSumOfAllTags(targetKey,ref))} 円",
          style:const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 60));
    } else if (includeFee == 0) {
      estimatedMonthlyIncome = Text(
          "${ArbeitCalculator().formatNumberWithComma(
            ArbeitCalculator().monthlyWageSum(widget.targetMonth,ref))} 円",
          style:const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 60));
    }
    PreferredSizeWidget? appbar;
    if(isAppBar){
        appbar = CustomAppBar(backButton: true);
  }
    


    return Scaffold(
        appBar:appbar,
        body: Column(children: [
          Container(
            color:BACKGROUND_COLOR,
            child: Row(children: [
              IconButton(
                onPressed: () {
                  decreasePgNumber();
                },
                icon: const Icon(Icons.arrow_back_ios),
                iconSize: 20,
                color:BLACK
                ),
            Text(
              widget.targetMonth,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color:BLACK
              ),
            ),
            IconButton(
                onPressed: () {
                  setState(() {
                    increasePgNumber();
                  });
                },
                icon: const Icon(Icons.arrow_forward_ios),
                iconSize: 20,
                color:BLACK
                ),
          ])),
          const Divider(height: 1),
          Expanded(
            child: Container(
              decoration:  BoxDecoration(color:BACKGROUND_COLOR),
              child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(children: [
                        SizedBox(width: SizeConfig.blockSizeHorizontal! * 5),
                        const Text(
                          '連結データ',
                          style: TextStyle(
                              fontSize: 27,
                              color: BLUEGREY,
                              fontWeight: FontWeight.bold),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                        padding:const EdgeInsets.symmetric(
                            horizontal: 20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: roundedBoxdecoration(radiusType: 1),
                                  child: Column(
                                      //crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("$year年 年収見込み  ",
                                            style:const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 27)),
                                        correctIndicator(),
                                        Text(
                                            "${ArbeitCalculator().formatNumberWithComma(
                                              ArbeitCalculator().yearlyWageSumWithAdditionalWorkTime(
                                                widget.targetMonth,ref))} 円",
                                            style:const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 60)),
                                        Text("$month月 月収見込み  ",
                                            style:const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 27)),
                                        estimatedMonthlyIncome,
                                        Row(children: [
                                          const Spacer(),
                                          includeFeeSwitch()
                                        ]),
                                        Row(children: [
                                          const Spacer(),
                                          TextButton(
                                              onPressed: () =>
                                                  showCulculateWayDialog(
                                                      context),
                                              style: const ButtonStyle(
                                                  padding:
                                                      WidgetStatePropertyAll(
                                                          EdgeInsets.zero)),
                                              child: const Text("値の計算方法について")),
                                        ]),
                                      ])),
                              const SizedBox(height: 2),
                              Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          SizeConfig.blockSizeHorizontal! * 0),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration:
                                              roundedBoxdecoration(radiusType: 2),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                               const Text("平均月収",
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 20)),
                                                const SizedBox(width: 15),
                                                Text(
                                                    "${ArbeitCalculator().formatNumberWithComma(
                                                      (ArbeitCalculator().yearlyWageSumWithAdditionalWorkTime(
                                                                        widget
                                                                            .targetMonth,ref) /
                                                        ArbeitCalculator().numberOfValidMonthNullsafe(
                                                                        widget
                                                                            .targetMonth,ref))
                                                                .round())} 円",
                                                    style:const TextStyle(
                                                        color: BLACK,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 40)),
                                              ]),
                                        ),
                                      ])),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: roundedBoxdecoration(radiusType: 2),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          SizeConfig.blockSizeVertical! * 2),
                                  child: Column(children: [
                                    Row(children: [
                                      const Text("”103万円の壁”まで",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 20)),
                                      IconButton(
                                          icon: const Icon(Icons.info,
                                              color: Colors.grey),
                                          onPressed: () => showTextDialog(
                                              context,
                                              "あなたの扶養者(親など)にかかる所得税が増加するラインです。"))
                                    ]),
                                    Text(
                                        "${ArbeitCalculator().formatNumberWithComma(1030000 -
                                          ArbeitCalculator().yearlyWageSumWithAdditionalWorkTime(
                                            widget.targetMonth,ref))} 円",
                                        style:const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 40)),
                                    //Row(children: [
                                    //   Text("超えないには？？",
                                    //       style: TextStyle(
                                    //           color: Colors.grey,
                                    //           fontSize: SizeConfig
                                    //                   .blockSizeHorizontal! *
                                    //               5)),
                                    // ]),
                                    // Text(
                                    //     "目安  月収" +
                                    //         formatNumberWithComma(returnRemainingIncome(1030000)) +
                                    //         " 円未満",
                                    //     style: TextStyle(
                                    //         fontWeight: FontWeight.bold,
                                    //         fontSize: SizeConfig
                                    //                 .blockSizeHorizontal! *
                                    //             5)),
                                    // SizedBox(
                                    //     height:
                                    //         SizeConfig.blockSizeVertical! * 1)
                                  ]),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: roundedBoxdecoration(radiusType: 3),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          SizeConfig.blockSizeVertical! * 2),
                                  child: Column(children: [
                                    Row(children: [
                                      const Text("”130万円の壁”まで",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize:20)),
                                      IconButton(
                                          icon: const Icon(Icons.info,
                                              color: Colors.grey),
                                          onPressed: () => showTextDialog(
                                              context,
                                              "あなたに社会保険料が科されるようになるラインです。"))
                                    ]),
                                    Text(
                                        "${ArbeitCalculator().formatNumberWithComma(1300000 -
                                          ArbeitCalculator().yearlyWageSumWithAdditionalWorkTime(
                                                    widget.targetMonth,ref) -
                                            ArbeitCalculator().yearlyFeeSumOfAllTags(
                                                    widget.targetMonth,ref))} 円",
                                        style:const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 40)),
                                    // Row(children: [
                                    //   Text("超えないには？？",
                                    //       style: TextStyle(
                                    //           color: Colors.grey,
                                    //           fontSize: SizeConfig
                                    //                   .blockSizeHorizontal! *
                                    //               5)),
                                    // ]),
                                    // Text(
                                    //     "目安  月収" +
                                    //         formatNumberWithComma(returnRemainingIncome(1300000)) +
                                    //         " 円未満",
                                    //     style: TextStyle(
                                    //         fontWeight: FontWeight.bold,
                                    //         fontSize: SizeConfig
                                    //                 .blockSizeHorizontal! *
                                    //             5)),
                                    // SizedBox(
                                    //     height:
                                    //         SizeConfig.blockSizeVertical! * 1)
                                  ]),
                                ),
                              )
                              ])),
                    const SizedBox(height: 30),
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(children: [
                        SizedBox(width: SizeConfig.blockSizeHorizontal! * 5),
                        const Text(
                          '個別データ',
                          style: TextStyle(
                              fontSize: 30,
                              color: BLUEGREY,
                              fontWeight: FontWeight.bold),
                        ),
                      ]),
                    ),
                    const SizedBox(height:5),
                    tagDataList(),
                    SizedBox(height: SizeConfig.blockSizeVertical! * 10),
                  ])),
            ),
          )
        ]),
      );
  }

  int returnRemainingIncome(int maxIncome){
    int remainingMonth = 12-ArbeitCalculator().numberOfValidMonth(widget.targetMonth,ref);
    if(remainingMonth == 0){
       return ((maxIncome-ArbeitCalculator().yearlyWageSumWithAdditionalWorkTime(widget.targetMonth,ref))).round();
    }else{
       return ((maxIncome-ArbeitCalculator().yearlyWageSumWithAdditionalWorkTime(widget.targetMonth,ref))
                                               /(12-ArbeitCalculator().numberOfValidMonth(widget.targetMonth,ref))).round();
    }
  }

  Widget correctIndicator() {
    if (ref.read(calendarDataProvider).arbeitData.isEmpty) {
      return const SizedBox();
    } else {
      return Row(children: [
        const Spacer(),
        Text("(修正分を含む)      ",
            style: TextStyle(
                color: Colors.grey,
                fontSize: SizeConfig.blockSizeHorizontal! * 3.5)),
      ]);
    }
  }

  void increasePgNumber() {
    String increasedMonth = "";

    if (widget.targetMonth.substring(5, 7) == "12") {
      int year = int.parse(widget.targetMonth.substring(0, 4));
      year += 1;
      setState(() {
        increasedMonth = "$year/01";
      });
    } else {
      int month = int.parse(widget.targetMonth.substring(5, 7));
      month += 1;
      setState(() {
        increasedMonth = widget.targetMonth.substring(0, 5) +
            month.toString().padLeft(2, '0');
      });
    }

    widget.targetMonth = increasedMonth;
  }

  void decreasePgNumber() {
    String decreasedMonth = "";

    if (widget.targetMonth.substring(5, 7) == "01") {
      int year = int.parse(widget.targetMonth.substring(0, 4));
      year -= 1;
      setState(() {
        decreasedMonth = "$year/12";
      });
    } else {
      int month = int.parse(widget.targetMonth.substring(5, 7));
      month -= 1;
      setState(() {
        decreasedMonth = widget.targetMonth.substring(0, 5) +
            month.toString().padLeft(2, '0');
      });
    }
    widget.targetMonth = decreasedMonth;
  }

  Widget includeFeeSwitch() {
    String buttonText = "交通費：含む";
    Function() onPress = () {
      setState(() {
        includeFee = 0;
      });
    };

    if (includeFee == 0) {
      buttonText = "交通費：含まない";
      onPress = () {
        setState(() {
          includeFee = 1;
        });
      };
    }

    return TextButton(
        onPressed: onPress,
        style: const ButtonStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.zero)),
        child: Text(buttonText));
  }

  Widget tagDataList() {
    final tagData = ref.watch(calendarDataProvider);
    List sortedData = tagData.tagData;
    String year = widget.targetMonth.substring(0, 4);
    String month = widget.targetMonth.substring(5, 7);
    String targetKey = "$year-$month";

    if (ref.watch(calendarDataProvider).sortedDataByMonth[targetKey] == null) {
      return Container(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Center(
              child: Text(
            "当月アルバイトデータなし",
            style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! * 7,
                color: charColor),
          )));
    } else {
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          Widget dateTimeData =
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              "時給：${ArbeitCalculator().formatNumberWithComma(sortedData.elementAt(index)["wage"])}円",
              style:  TextStyle(
                  color:  FORGROUND_COLOR,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "片道交通費：${ArbeitCalculator().formatNumberWithComma(sortedData.elementAt(index)["fee"])}円",
              style:  TextStyle(
                  color:  FORGROUND_COLOR,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            )
          ]);

          if (sortedData.elementAt(index)["isBeit"] == 1) {
            return Column(children: [
                Container(
                    width: SizeConfig.blockSizeHorizontal! * 95,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: sortedData.elementAt(index)["color"], // コンテナの背景色
                      borderRadius: BorderRadius.circular(12.0), // 角丸の半径
                    ),
                    child: Column(children: [
                      Row(children: [
                        dateTimeData,
                        const SizedBox(width: 15),
                        Expanded(child:
                        Text(
                          sortedData.elementAt(index)["title"] ?? "(詳細なし)",
                          style:  TextStyle(
                              color:  FORGROUND_COLOR,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.clip
                              ),
                        )
                        )
                      ]),
                      separetedDataStats(sortedData.elementAt(index))
                    ])),
              const SizedBox(height: 15)
            ]);
          } else {
            return const SizedBox();
          }
        },
        itemCount: sortedData.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      );
    }
  }

  Widget separetedDataStats(tagData) {
    Map sortedDataByMonth = ref.watch(calendarDataProvider).sortedDataByMonth;
    String year = widget.targetMonth.substring(0, 4);
    String month = widget.targetMonth.substring(5, 7);
    String targetKey = "$year-$month";
    String targetMonthForDisplay = "$month月";
    String targetYearForDisplay = "$year年";

    return Container(
        width: SizeConfig.blockSizeHorizontal! * 95,
        color:  FORGROUND_COLOR,
        child: Padding(
            padding: const EdgeInsets.all(8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("$targetMonthForDisplayのデータ",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Row(children: [
                const Text("労働時間　  ", style: TextStyle(color: Colors.grey)),
                Text("${ArbeitCalculator().monthlyWorkTimeSum(tagData, targetKey,ref).inHours} 時間${ArbeitCalculator().monthlyWorkTimeSum(tagData, targetKey,ref).inMinutes % 60} 分"),
              ]),
              const SizedBox(height: 2),
              Row(children: [
                const Text("給料見込み  ", style: TextStyle(color: Colors.grey)),
                Text("${ArbeitCalculator().formatNumberWithComma(
                  ArbeitCalculator().culculateWage(
                    ArbeitCalculator().monthlyWorkTimeSumWithAdditionalWorkTime(
                            tagData, targetKey,ref),
                        tagData["wage"]))} 円"),
              ]),
              const SizedBox(height: 2),
              Row(children: [
                const Text("交通費総額  ", style: TextStyle(color: Colors.grey)),
                Text("${ArbeitCalculator().formatNumberWithComma(
                  ArbeitCalculator().monthlyFeeSum(tagData, targetKey,ref))} 円"),
              ]),
              const SizedBox(height: 7),
              Text("$targetYearForDisplay 通年のデータ",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Row(children: [
                const Text("労働時間　  ", style: TextStyle(color: Colors.grey)),
                Text("${ArbeitCalculator().yearlyWorkTimeSum(tagData, targetKey,ref).inHours} 時間${ArbeitCalculator().yearlyWorkTimeSum(tagData, targetKey,ref).inMinutes % 60} 分"),
              ]),
              const SizedBox(height: 2),
              Row(children: [
                const Text("給料見込み  ", style: TextStyle(color: Colors.grey)),
                Text("${ArbeitCalculator().formatNumberWithComma(
                  ArbeitCalculator().culculateWage(
                    ArbeitCalculator().yearlyWorkTimeSum(tagData, targetKey,ref),
                        tagData["wage"]))} 円"),
              ]),
              const SizedBox(height: 2),
              Row(children: [
                const Text("交通費総額  ", style: TextStyle(color: Colors.grey)),
                Text("${ArbeitCalculator().formatNumberWithComma(
                  ArbeitCalculator().yearlyFeeSum(tagData, targetKey,ref))} 円"),
              ]),
              const SizedBox(height: 15),
              collectingEntryList(tagData, targetKey)
            ])));
  }

  KeyboardActionsConfig _buildConfig(tagData, targetKey,
      TextEditingController controller, List<FocusNode> nodeList) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor:  FORGROUND_COLOR,
      nextFocus: false,
      actions: [
        for (var _node in nodeList) ...{
          KeyboardActionsItem(
            focusNode: _node,
            toolbarAlignment: MainAxisAlignment.start,
            displayArrows: false,
            toolbarButtons: [
              (node) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Stack(
                    children: [
                      Container(
                          margin: const EdgeInsets.only(left: 0),
                          child: Row(children: [
                            SizedBox(
                                width: SizeConfig.blockSizeHorizontal! * 80),
                            GestureDetector(
                              onTap: () {
                                upDateConfigInfo(tagData, targetKey,
                                    controller.text, nodeList.indexOf(_node));
                                node.unfocus();
                              },
                              child: const Text(
                                "完了",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ])),
                    ],
                  ),
                );
              }
            ],
          ),
        }
      ],
    );
  }

  Widget collectingEntryList(tagData, targetKey) {
    String year = targetKey.substring(0, 4);
    List<String> targetKeys = [
      "$year-01",
      "$year-02",
      "$year-03",
      "$year-04",
      "$year-05",
      "$year-06",
      "$year-07",
      "$year-08",
      "$year-09",
      "$year-10",
      "$year-11",
      "$year-12",
    ];

    return Column(children: [
      const Align(
          alignment: Alignment.centerLeft,
          child: Text("修正記入", style: TextStyle(fontWeight: FontWeight.bold))),
      const SizedBox(height: 5),
      Row(children: [
        const Text("   年/月   ", style: TextStyle(color: Colors.grey)),
        const Spacer(),
        const Text("予測値", style: TextStyle(color: Colors.grey)),
        const Spacer(),
        SizedBox(width: SizeConfig.blockSizeHorizontal! * 5),
        const Text("実際の振込額", style: TextStyle(color: Colors.grey)),
        const Spacer()
      ]),
      ListView.separated(
          itemBuilder: (context, index) {
            TextEditingController controller = TextEditingController();
            controller.selection = TextSelection.fromPosition(
              //入力文字のカーソルの位置を管理
              TextPosition(offset: controller.text.length),
            ); //入力されている文字数を取得し、その位置にカーソルを移動することで末尾にカーソルを当てる
            final FocusNode nodeText1 = FocusNode();
            final FocusNode nodeText2 = FocusNode();
            final FocusNode nodeText3 = FocusNode();
            final FocusNode nodeText4 = FocusNode();
            final FocusNode nodeText5 = FocusNode();
            final FocusNode nodeText6 = FocusNode();
            final FocusNode nodeText7 = FocusNode();
            final FocusNode nodeText8 = FocusNode();
            final FocusNode nodeText9 = FocusNode();
            final FocusNode nodeText10 = FocusNode();
            final FocusNode nodeText11 = FocusNode();
            final FocusNode nodeText12 = FocusNode();
            final List<FocusNode> nodeList = [
              nodeText1,
              nodeText2,
              nodeText3,
              nodeText4,
              nodeText5,
              nodeText6,
              nodeText7,
              nodeText8,
              nodeText9,
              nodeText10,
              nodeText11,
              nodeText12,
            ];

            controller.text =
                (ArbeitCalculator().returnCorrectedWage(tagData, targetKeys.elementAt(index),ref))
                    .toString();

            return Row(children: [
              Text(targetKeys.elementAt(index)),
              const Spacer(),
              SizedBox(width: SizeConfig.blockSizeHorizontal! * 3),
              Text("${ArbeitCalculator().formatNumberWithComma(
                ArbeitCalculator().culculateWage(
                  ArbeitCalculator().monthlyWorkTimeSumWithAdditionalWorkTime(
                              tagData, targetKeys.elementAt(index),ref),
                          tagData["wage"]) +
                    ArbeitCalculator().monthlyFeeSum(tagData, targetKeys.elementAt(index),ref))} 円"),
              SizedBox(width: SizeConfig.blockSizeHorizontal! * 5),
              SizedBox(
                  width: SizeConfig.blockSizeHorizontal! * 30,
                  height: SizeConfig.blockSizeVertical! * 3,
                  child: KeyboardActions(
                      config: _buildConfig(
                          tagData, targetKey, controller, nodeList),
                      child: CupertinoTextField(
                        controller: controller,
                        focusNode: nodeList[index],
                        textInputAction: TextInputAction.done,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: false),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^[0-9]+$')),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textAlign: TextAlign.end,
                        padding: const EdgeInsets.all(2),
                        onSubmitted: (value) async {
                          upDateConfigInfo(tagData, targetKey, value, index);
                        },
                      ))),
              const Text(" 円"),
            ]);
          },
          separatorBuilder: (context, index) {
            return Container(height: 5);
          },
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 12),
    ]);
  }

  Future<void> upDateConfigInfo(
      tagData, targetKey, String value, int index) async {
    String year = targetKey.substring(0, 4);
    List<String> targetKeys = [
      "$year-01",
      "$year-02",
      "$year-03",
      "$year-04",
      "$year-05",
      "$year-06",
      "$year-07",
      "$year-08",
      "$year-09",
      "$year-10",
      "$year-11",
      "$year-12",
    ];
    int targetTagId = tagData["id"];
    String targetMonth = targetKeys.elementAt(index);

    int wage = int.parse(value);
    bool found = false;

    for (var data in ref.read(calendarDataProvider).arbeitData) {
      int id = data["id"];
      String month = data["month"];
      int tagId = data["tagId"];

      if (month == targetMonth && tagId == targetTagId) {
        found = true;
        await ArbeitDatabaseHelper().updateArbeit({
          "id": id,
          "tagId": targetTagId,
          "month": targetMonth,
          "wage": wage
        });
        ref.read(taskDataProvider).isRenewed = true;
        ref.read(calendarDataProvider.notifier).state = CalendarData();
        while (ref.read(taskDataProvider).isRenewed != false) {
          await Future.delayed(const Duration(microseconds: 1));
        }
        setState(() {});
        break;
      }
    }
    if (!found) {
      await ArbeitDatabaseHelper().resisterArbeitToDB(
          {"tagId": targetTagId, "month": targetMonth, "wage": wage});
      ref.read(taskDataProvider).isRenewed = true;
      ref.read(calendarDataProvider.notifier).state = CalendarData();
      while (ref.read(taskDataProvider).isRenewed != false) {
        await Future.delayed(const Duration(milliseconds: 1));
      }
      setState(() {});
    }
  }



  void showTextDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text(text),
            content: const Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(height: 5),
              Text(
                  "※2024年2月現在の情報に基づきます。最新の情報はご自身でお確かめください。\n" "※一般的な大学生の所得モデルにおける例を示しています。個人の状況により適用制度に若干の差異がございますので、詳細はご自身でお確かめください。",
                  style: TextStyle(color: Colors.grey))
            ]));
      },
    );
  }

  void showCulculateWayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
            title: Text("値の算出方法\n\n労働時間(1分単位) × 時給"),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                  "・6時間以上で45分、8時間以上で60分休憩と仮定\n・8時間を超える労働については給料を1.25倍\n・早朝5時以前、深夜22時以降の労働については給料を1.25倍\n"),
              SizedBox(height: 5),
              Text(
                  "※労働基準法に基づいた、一般的なアルバイトの時給計算式で算出しております。例外につきましては”修正記入”でご対応ください。",
                  style: TextStyle(color: Colors.grey))
            ]));
      },
    );
  }
}


