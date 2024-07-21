import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/tasklist_sort_date.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

List<String> targetMonthTasks = [];
List<String> targetMonthDoneTasks = [];
List<Duration> targetMonthStudyTimes = [];
Duration targetMonthTimeSum = Duration.zero;

List<String> monthlyTasks = [];
List<String> monthlyDoneTasks = [];
List<Duration> monthlyStudyTimes = [];
Duration monthlyTimeSum = Duration.zero;

List<String> weeklyTasks = [];
List<String> weeklyDoneTasks = [];
Duration weeklyTimeSum = Duration.zero;

DateTime now = DateTime.now();
DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

DateTime firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
DateTime lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));

String formattedDate = DateFormat('MM月dd日').format(now);
int circularIndicatorState = 2;

class StudyProgressIndicator extends StatefulWidget {
  const StudyProgressIndicator({super.key});

  @override
  StudyProgressIndicatorState createState() => StudyProgressIndicatorState();
}

Widget buildStudyProgressIndicator(
  BuildContext context,
  List<Map<String, dynamic>> targetMonthData,
  List<Map<String, dynamic>> thisMonthData,
) {
  targetMonthTasks = [];
  targetMonthDoneTasks = [];
  targetMonthTimeSum = Duration.zero;
  targetMonthStudyTimes = [];

  monthlyTasks = [];
  monthlyDoneTasks = [];
  monthlyTimeSum = Duration.zero;
  monthlyStudyTimes = [];

  weeklyTasks = [];
  weeklyDoneTasks = [];
  weeklyTimeSum = Duration.zero;

  //今"月"の累計を出す処理
  for (int i = 0; i < thisMonthData.length; i++) {
    Map target = thisMonthData.elementAt(i);

    monthlyTimeSum += target["time"];
    monthlyStudyTimes.add(target["time"]);

    for (int ind = 0; ind < target["plan"].length; ind++) {
      if (target["plan"].elementAt(ind).trim() != "") {
        monthlyTasks.add(target["date"]);
      }
    }

    for (int ind = 0; ind < target["record"].length; ind++) {
      if (target["record"].elementAt(ind).trim() != "" &&
          monthlyDoneTasks.length < monthlyTasks.length) {
        monthlyDoneTasks.add(target["date"]);
      }
    }

    //今"週"の累計を出す処理
    DateTime targetDay = DateTime(
      int.parse(target["date"].substring(0, 4)),
      int.parse(target["date"].substring(5, 7)),
      int.parse(target["date"].substring(8, 10)),
    );

    if (targetDay.isAfter(firstDayOfWeek) &&
        targetDay.isBefore(lastDayOfWeek)) {
      weeklyTimeSum += target["time"];

      for (int ind = 0; ind < target["plan"].length; ind++) {
        if (target["plan"].elementAt(ind).trim() != "") {
          weeklyTasks.add(target["date"]);
        }
      }

      for (int ind = 0; ind < target["record"].length; ind++) {
        if (target["record"].elementAt(ind).trim() != "" &&
            weeklyDoneTasks.length < weeklyTasks.length) {
          weeklyDoneTasks.add(target["date"]);
        }
      }
    }
  }

  for (int i = 0; i < targetMonthData.length; i++) {
    Map target = targetMonthData.elementAt(i);

    targetMonthTimeSum += target["time"];
    targetMonthStudyTimes.add(target["time"]);

    DateTime targetDay = DateTime(
      int.parse(target["date"].substring(0, 4)),
      int.parse(target["date"].substring(5, 7)),
      int.parse(target["date"].substring(8, 10)),
    );
  }

  // for (int i = 0; i < data.length; i++) {
  //   allTasks["${data[i]["title"]}${data[i]["dtEnd"]}"] =
  //       DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"]);
  //   if (data[i]["isDone"] == 1) {
  //     allDoneTasks["${data[i]["title"]}${data[i]["dtEnd"]}"] =
  //         DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"]);
  //   }

  //   if (DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"])
  //           .isAfter(firstDayOfMonth) &&
  //       DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"])
  //           .isBefore(lastDayOfMonth)) {
  //     monthlyTasks["${data[i]["title"]}${data[i]["dtEnd"]}"] =
  //         DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"]);
  //     if (data[i]["isDone"] == 1) {
  //       monthlyDoneTasks["${data[i]["title"]}${data[i]["dtEnd"]}"] =
  //           DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"]);
  //     }
  //   }

  //   if (DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"])
  //           .isAfter(firstDayOfWeek) &&
  //       DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"])
  //           .isBefore(lastDayOfWeek)) {
  //     weeklyTasks["${data[i]["title"]}${data[i]["dtEnd"]}"] =
  //         DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"]);
  //     if (data[i]["isDone"] == 1) {
  //       weeklyDoneTasks["${data[i]["title"]}${data[i]["dtEnd"]}"] =
  //           DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"]);
  //     }
  //   }
  // }

  return const StudyProgressIndicator();
}

class StudyProgressIndicatorState extends State<StudyProgressIndicator> {
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
        "$formattedDate(${"日月火水木金土"[now.weekday % 7]})",
        style: TextStyle(
            fontSize: SizeConfig.blockSizeHorizontal! * 7,
            fontWeight: FontWeight.w600),
      ),
      const Spacer(),
      Text(
        "計画の達成度",
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
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              InkWell(
                  onTap: () {
                    setState(() {
                      circularIndicatorState = 2;
                    });
                  },
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Text("今週    "),
                          const Icon(Icons.timer, color: Colors.grey, size: 15),
                          Text(
                              "  ${weeklyTimeSum.inHours} 時間${weeklyTimeSum.inMinutes.remainder(60)} 分",
                              style: const TextStyle(color: Colors.grey)),
                        ]),
                        SizedBox(
                            height: SizeConfig.blockSizeVertical! * 2.5,
                            width: SizeConfig.blockSizeHorizontal! * 55,
                            child: SizedBox(
                              height: SizeConfig.blockSizeVertical! * 2,
                              width: SizeConfig.blockSizeHorizontal! * 40,
                              child: HpGauge3Color(
                                  currentHp: weeklyDoneTasks.length,
                                  maxHp: weeklyTasks.length,
                                  isEmpty: weeklyTasks.isEmpty),
                            ))
                      ])),
              SizedBox(height: SizeConfig.blockSizeVertical! * 1),
              InkWell(
                  onTap: () {
                    setState(() {
                      circularIndicatorState = 1;
                    });
                  },
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Text("今月    "),
                          const Icon(Icons.timer, color: Colors.grey, size: 15),
                          Text(
                              "  ${monthlyTimeSum.inHours} 時間${monthlyTimeSum.inMinutes.remainder(60)} 分",
                              style: const TextStyle(color: Colors.grey)),
                        ]),
                        SizedBox(
                            height: SizeConfig.blockSizeVertical! * 2.5,
                            width: SizeConfig.blockSizeHorizontal! * 55,
                            child: SizedBox(
                              height: SizeConfig.blockSizeVertical! * 2,
                              width: SizeConfig.blockSizeHorizontal! * 40,
                              child: HpGauge3Color(
                                  currentHp: monthlyDoneTasks.length,
                                  maxHp: monthlyTasks.length,
                                  isEmpty: monthlyTasks.isEmpty),
                            )),
                      ])),
              const SizedBox(height: 10),
              nullGuard(
                  targetMonthStudyTimes,
                  SizedBox(
                    height: SizeConfig.blockSizeVertical! * 10,
                    width: SizeConfig.blockSizeHorizontal! * 55,
                    child: targetMonthStudyTimeChart(
                        SizeConfig.blockSizeVertical! * 10,
                        SizeConfig.blockSizeHorizontal! * 50),
                  ))
            ])
          ]),
      const Divider(
        height: 1,
      ),
    ]);
  }

  Widget targetMonthStudyTimeChart(double maxHeight, double maxWidth) {
    Duration maxDuration = Duration.zero;

    if (targetMonthStudyTimes.isNotEmpty) {
      maxDuration =
          targetMonthStudyTimes.reduce((a, b) => a.compareTo(b) > 0 ? a : b);
    }

    int maxMinute = 1440;
    if (maxDuration.inHours < 8) {
      maxMinute = 480;
    } else if (maxDuration.inHours < 16) {
      maxMinute = 960;
    }
    double oneMinHeight = maxHeight / maxMinute;
    double oneDayWidth = maxWidth / targetMonthStudyTimes.length;

    Widget gauge = const SizedBox();
    if (targetMonthStudyTimes.isNotEmpty && maxDuration.inMinutes != 0) {
      gauge = SizedBox(
          height: maxHeight,
          child: Row(children: [
            const VerticalDivider(
              width: 1,
            ),
            Column(children: [
              Text((maxMinute / 60).round().toString(),
                  style: const TextStyle(fontSize: 10)),
              const Spacer(),
              Text((maxMinute / 120).round().toString(),
                  style: const TextStyle(fontSize: 10)),
              const Spacer(),
              const Text("0h", style: TextStyle(fontSize: 10)),
            ])
          ]));
    }

    return Row(children: [
      ListView.builder(
        itemBuilder: (context, index) {
          int oneDayHeight = targetMonthStudyTimes.elementAt(index).inMinutes;
          return Column(children: [
            SizedBox(
              width: oneDayWidth,
              height: oneMinHeight * (maxMinute - oneDayHeight),
            ),
            Container(
              width: oneDayWidth,
              height: oneMinHeight * oneDayHeight,
              decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(2.0),
                      topRight: Radius.circular(2.0))),
            )
          ]);
        },
        itemCount: targetMonthStudyTimes.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
      ),
      gauge
    ]);
  }

  Widget nullGuard(targetData, widget) {
    if (targetData.isEmpty) {
      return const SizedBox();
    } else {
      return widget;
    }
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
        Text(" $statusText  ",
            style: TextStyle(fontSize: SizeConfig.blockSizeVertical! * 2)),
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
