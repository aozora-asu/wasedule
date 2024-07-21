import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/tasklist_sort_date.dart';
import 'package:intl/intl.dart';

import 'package:percent_indicator/percent_indicator.dart';

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

String formattedDate = DateFormat('MM月dd日').format(now);
int circularIndicatorState = 2;

class TaskProgressIndicator extends StatefulWidget {
  const TaskProgressIndicator({super.key});

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

  // if (allTasks.isEmpty) {
  //   allTasks["仮データ"] = DateTime.now();
  //   allDoneTasks["仮データ"] = DateTime.now();
  // }

  // if (monthlyTasks.isEmpty) {
  //   monthlyTasks["仮データ"] = DateTime.now();
  //   monthlyDoneTasks["仮データ"] = DateTime.now();
  // }

  // if (weeklyTasks.isEmpty) {
  //   weeklyTasks["仮データ"] = DateTime.now();
  //   weeklyDoneTasks["仮データ"] = DateTime.now();
  // }
  return const TaskProgressIndicator();
}

class TaskProgressIndicatorState extends State<TaskProgressIndicator> {
  ExpandableController expController = ExpandableController();

  @override
  void initState() {
    super.initState();
    expController = ExpandableController(initialExpanded: true);
  }

  Widget circularPercentIndicator() {
    int numOfDoneTasks = 0;
    int numOfAllTasks = 1;
    String centreText = "";
    if (circularIndicatorState == 1) {
      numOfDoneTasks = monthlyDoneTasks.length;
      numOfAllTasks = monthlyTasks.length;
      centreText = "今月";
      if (monthlyTasks.isEmpty) {
        numOfAllTasks = 1;
      }
    } else if (circularIndicatorState == 2) {
      numOfDoneTasks = weeklyDoneTasks.length;
      numOfAllTasks = weeklyTasks.length;
      centreText = "今週";
      if (weeklyTasks.isEmpty) {
        numOfAllTasks = 1;
      }
    } else {
      numOfDoneTasks = allDoneTasks.length;
      numOfAllTasks = allTasks.length;
      centreText = "全期間";
      if (allTasks.isEmpty) {
        numOfAllTasks = 1;
      }
    }
    return CircularPercentIndicator(
        radius: SizeConfig.blockSizeHorizontal! * 20,
        lineWidth: SizeConfig.blockSizeHorizontal! * 3.5,
        percent: numOfDoneTasks / numOfAllTasks,
        animation: true,
        animationDuration: 1500,
        circularStrokeCap: CircularStrokeCap.round,
        center: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            centreText,
            style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! * 5,
                fontWeight: FontWeight.w400),
          ),
          Text(
            "${((numOfDoneTasks / numOfAllTasks) * 100).round()}%",
            style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! * 9,
                fontWeight: FontWeight.w700),
          ),
        ]),
        progressColor: getCurrentHpColor(numOfDoneTasks, numOfAllTasks),
        backgroundColor: WIDGET_OUTLINE_COLOR);
  }

  Color getCurrentHpColor(int hp, int max) {
    if (hp > max / 2) {
      return const Color.fromARGB(255, 139, 255, 143);
    }
    if (hp > max / 5) {
      return const Color.fromARGB(255, 255, 225, 135);
    }
    return const Color.fromARGB(255, 255, 159, 159);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return ExpandablePanel(
      collapsed: const Divider(
        height: 1,
      ),
      header: headerItem(),
      expanded: indicatorBody(),
      controller: expController,
    );
  }

  Widget headerItem() {
    return SizedBox(
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      const SizedBox(width: 10),
      Text(
        "$formattedDate(${"日月火水木金土日"[now.weekday % 7]})",
        style: TextStyle(
            fontSize: SizeConfig.blockSizeHorizontal! * 7,
            fontWeight: FontWeight.w600),
      ),
      const Spacer(),
      Text(
        "タスクの進捗度",
        style: TextStyle(
          fontSize: SizeConfig.blockSizeHorizontal! * 5,
          fontWeight: FontWeight.bold,
        ),
      )
    ]));
  }

  Widget indicatorBody() {
    return Column(children: [
      SizedBox(
          height: SizeConfig.blockSizeVertical! * 2,
          width: SizeConfig.blockSizeHorizontal! * 100),
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: SizeConfig.blockSizeHorizontal! * 45,
                height: SizeConfig.blockSizeHorizontal! * 45,
                child: circularPercentIndicator()),
            Column(children: [
              SizedBox(
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
                      SizedBox(
                        height: SizeConfig.blockSizeVertical! * 1.75,
                        width: SizeConfig.blockSizeHorizontal! * 40,
                        child: HpGauge3Color(
                            currentHp: weeklyDoneTasks.length,
                            maxHp: weeklyTasks.length,
                            isEmpty: weeklyTasks.isEmpty),
                      )
                    ]),
                  )),
              SizedBox(
                height: SizeConfig.blockSizeVertical! * 4,
                width: SizeConfig.blockSizeHorizontal! * 55,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      circularIndicatorState = 1;
                    });
                  },
                  child: Row(children: [
                    const Text("今月    "),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 1.75,
                      width: SizeConfig.blockSizeHorizontal! * 40,
                      child: HpGauge3Color(
                          currentHp: monthlyDoneTasks.length,
                          maxHp: monthlyTasks.length,
                          isEmpty: monthlyTasks.isEmpty),
                    )
                  ]),
                ),
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical! * 4,
                width: SizeConfig.blockSizeHorizontal! * 55,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      circularIndicatorState = 0;
                    });
                  },
                  child: Row(children: [
                    const Text("全て    "),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 1.75,
                      width: SizeConfig.blockSizeHorizontal! * 40,
                      child: HpGauge3Color(
                          currentHp: allDoneTasks.length,
                          maxHp: allTasks.length,
                          isEmpty: allTasks.isEmpty),
                    )
                  ]),
                ),
              )
            ])
          ]),
      const Divider(
        height: 1,
      ),
    ]);
  }
}

class HpGauge3Color extends StatelessWidget {
  final bool isEmpty;
  final int currentHp;
  late int maxHp;

  HpGauge3Color(
      {required this.currentHp,
      required this.maxHp,
      required this.isEmpty,
      super.key});

  @override
  Widget build(BuildContext context) {
    String statusText = "0/0";

    if (!isEmpty) {
      statusText = '${currentHp.toString().padLeft(2, '  ')}/$maxHp';
    } else {
      maxHp += 1;
    }

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
        Text(statusText,
            style: TextStyle(fontSize: SizeConfig.blockSizeVertical! * 1.5)),
      ],
    );
  }

  Color getCurrentHpColor(int hp) {
    if (hp > maxHp / 2) {
      return const Color.fromARGB(255, 139, 255, 143);
    }
    if (hp > maxHp / 5) {
      return const Color.fromARGB(255, 255, 225, 135);
    }
    return const Color.fromARGB(255, 255, 159, 159);
  }
}
