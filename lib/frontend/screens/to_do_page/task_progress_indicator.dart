import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:intl/intl.dart';
import '../common/float_button.dart';
import 'dart:async';
import 'to_do_page.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:math';

Map<String, DateTime> allTasks = {};
Map<String, DateTime> allDoneTasks = {};
Map<String, DateTime> monthlyTasks = {};
Map<String, DateTime> monthlyDoneTasks = {};
Map<String, DateTime> weeklyTasks = {};
Map<String, DateTime> weeklyDoneTasks = {};

DateTime now = DateTime.now();
DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

DateTime firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
DateTime lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));

String formattedDate = DateFormat('MM月dd日(EEE)').format(now);
int circularIndicatorState = 0;

class TaskProgressIndicator extends StatefulWidget {
  @override
  TaskProgressIndicatorState createState() => TaskProgressIndicatorState();
}

Widget buildTaskProgressIndicator(
    BuildContext context, List<Map<String, dynamic>> data) {
  for (int i = 0; i < data.length; i++) {
    allTasks["${data[i]["title"]}${data[i]["dtEnd"]}"] =
        DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"]);
    if (data[i]["isDone"] == 1) {
      allDoneTasks["${data[i]["title"]}${data[i]["dtEnd"]}"] =
          DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"]);
    }

    if (DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"])
            .isAfter(firstDayOfMonth) &&
        DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"])
            .isBefore(lastDayOfMonth)) {
      monthlyTasks["${data[i]["title"]}${data[i]["dtEnd"]}"] =
          DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"]);
      if (data[i]["isDone"] == 1) {
        monthlyDoneTasks["${data[i]["title"]}${data[i]["dtEnd"]}"] =
            DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"]);
      }
    }

    if (DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"])
            .isAfter(firstDayOfWeek) &&
        DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"])
            .isBefore(lastDayOfWeek)) {
      weeklyTasks["${data[i]["title"]}${data[i]["dtEnd"]}"] =
          DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"]);
      if (data[i]["isDone"] == 1) {
        weeklyDoneTasks["${data[i]["title"]}${data[i]["dtEnd"]}"] =
            DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"]);
      }
    }
  }

  if(allTasks.isEmpty){
    allTasks["仮データ"] = DateTime.now();
    allDoneTasks["仮データ"] = DateTime.now();
  }

  if(monthlyTasks.isEmpty){
    monthlyTasks["仮データ"] = DateTime.now();
    monthlyDoneTasks["仮データ"] = DateTime.now();
  }

  if(weeklyTasks.isEmpty){
    weeklyTasks["仮データ"] = DateTime.now();
    weeklyDoneTasks["仮データ"] = DateTime.now();
  }
  return TaskProgressIndicator();
}

class TaskProgressIndicatorState extends State<TaskProgressIndicator> {
  Widget circularPercentIndicator() {
    if (circularIndicatorState == 1) {
      return CircularPercentIndicator(
          radius: SizeConfig.blockSizeHorizontal! * 20,
          lineWidth: SizeConfig.blockSizeHorizontal! * 3.5,
          percent: monthlyDoneTasks.length / monthlyTasks.length,
          animation: true,
          animationDuration: 1500,
          circularStrokeCap: CircularStrokeCap.round,
          center:
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              "今月",
              style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal! * 5,
                  fontWeight: FontWeight.w400),
            ),
            Text(
              "${((monthlyDoneTasks.length / monthlyTasks.length) * 100).round()}%",
              style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal! * 9,
                  fontWeight: FontWeight.w700),
            ),
          ]),
          progressColor:
              getCurrentHpColor(monthlyDoneTasks.length, monthlyTasks.length),
          backgroundColor: WIDGET_OUTLINE_COLOR);
    } else if (circularIndicatorState == 2) {
      return CircularPercentIndicator(
          radius: SizeConfig.blockSizeHorizontal! * 20,
          lineWidth: SizeConfig.blockSizeHorizontal! * 3.5,
          percent: weeklyDoneTasks.length / weeklyTasks.length,
          animation: true,
          animationDuration: 1500,
          circularStrokeCap: CircularStrokeCap.round,
          center:
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              "今週",
              style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal! * 5,
                  fontWeight: FontWeight.w400),
            ),
            Text(
              "${((weeklyDoneTasks.length / weeklyTasks.length) * 100).round()}%",
              style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal! * 9,
                  fontWeight: FontWeight.w700),
            ),
          ]),
          progressColor:
              getCurrentHpColor(weeklyDoneTasks.length, weeklyTasks.length),
          backgroundColor: WIDGET_OUTLINE_COLOR);
    } else {
      return CircularPercentIndicator(
          radius: SizeConfig.blockSizeHorizontal! * 20,
          lineWidth: SizeConfig.blockSizeHorizontal! * 3.5,
          percent: allDoneTasks.length / allTasks.length,
          animation: true,
          animationDuration: 1500,
          circularStrokeCap: CircularStrokeCap.round,
          center:
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              "全期間",
              style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal! * 5,
                  fontWeight: FontWeight.w400),
            ),
            Text(
              "${((allDoneTasks.length / allTasks.length) * 100).round()}%",
              style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal! * 9,
                  fontWeight: FontWeight.w700),
            ),
          ]),
          progressColor:
              getCurrentHpColor(allDoneTasks.length, allTasks.length),
          backgroundColor: WIDGET_OUTLINE_COLOR);
    }
  }

  Color getCurrentHpColor(int hp, int max) {
    if (hp > max / 2) {
      return Color.fromARGB(255, 139, 255, 143);
    }
    if (hp > max / 5) {
      return Color.fromARGB(255, 255, 225, 135);
    }
    return Color.fromARGB(255, 255, 159, 159);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Column(children: [
      Container(
          height: SizeConfig.blockSizeVertical! * 2,
          width: SizeConfig.blockSizeHorizontal! * 100),
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: SizeConfig.blockSizeHorizontal! * 45,
                height: SizeConfig.blockSizeHorizontal! * 45,
                child: circularPercentIndicator()),
            Column(children: [
              Container(
                  height: SizeConfig.blockSizeHorizontal! * 20,
                  width: SizeConfig.blockSizeHorizontal! * 55,
                  child: Column(children: [
                    Text(
                      "$formattedDate",
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal! * 7.5,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "タスクの進捗度",
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal! * 5,
                          fontWeight: FontWeight.w500),
                    )
                  ])),
              Container(
                  height: SizeConfig.blockSizeVertical! * 4,
                  width: SizeConfig.blockSizeHorizontal! * 55,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        circularIndicatorState = 2;
                      });
                    },
                    child: Row(children: [
                      const Text("今週    "),
                      Container(
                        height: SizeConfig.blockSizeHorizontal! * 3.5,
                        width: SizeConfig.blockSizeHorizontal! * 40,
                        child: HpGauge3Color(
                            currentHp: weeklyDoneTasks.length,
                            maxHp: weeklyTasks.length),
                      )
                    ]),
                  )),
              Container(
                height: SizeConfig.blockSizeHorizontal! * 8,
                width: SizeConfig.blockSizeHorizontal! * 55,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      circularIndicatorState = 1;
                    });
                  },
                  child: Row(children: [
                    const Text("今月    "),
                    Container(
                      height: SizeConfig.blockSizeHorizontal! * 3.5,
                      width: SizeConfig.blockSizeHorizontal! * 40,
                      child: HpGauge3Color(
                          currentHp: monthlyDoneTasks.length,
                          maxHp: monthlyTasks.length),
                    )
                  ]),
                ),
              ),
              Container(
                height: SizeConfig.blockSizeHorizontal! * 8,
                width: SizeConfig.blockSizeHorizontal! * 55,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      circularIndicatorState = 0;
                    });
                  },
                  child: Row(children: [
                    const Text("全て    "),
                    Container(
                      height: SizeConfig.blockSizeHorizontal! * 3.5,
                      width: SizeConfig.blockSizeHorizontal! * 40,
                      child: HpGauge3Color(
                          currentHp: allDoneTasks.length,
                          maxHp: allTasks.length),
                    )
                  ]),
                ),
              )
            ])
          ])
    ]);
  }
}

class HpGauge3Color extends StatelessWidget {
  const HpGauge3Color({required this.currentHp, required this.maxHp, Key? key})
      : super(key: key);

  final int currentHp;
  final int maxHp;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            child: LinearProgressIndicator(
              value: currentHp / maxHp,
              valueColor: AlwaysStoppedAnimation(getCurrentHpColor(currentHp)),
              backgroundColor: WIDGET_OUTLINE_COLOR,
              minHeight: 20,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        Text('${currentHp.toString().padLeft(2, '  ')}/$maxHp',
            style:TextStyle(fontSize:SizeConfig.blockSizeVertical! *1.5)
        ),
      ],
    );
  }

  Color getCurrentHpColor(int hp) {
    if (hp > maxHp / 2) {
      return Color.fromARGB(255, 139, 255, 143);
    }
    if (hp > maxHp / 5) {
      return Color.fromARGB(255, 255, 225, 135);
    }
    return Color.fromARGB(255, 255, 159, 159);
  }
}
