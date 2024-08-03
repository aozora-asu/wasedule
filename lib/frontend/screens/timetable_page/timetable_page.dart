import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/sharepreference.dart';
import 'package:flutter_calandar_app/frontend/screens/common/tutorials.dart';
import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/syllabus_query_request.dart';
import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/syllabus_query_result.dart';
import 'package:flutter_calandar_app/frontend/screens/setting_page/timetable_setting.dart';
import 'package:flutter_calandar_app/static/constant.dart';
import 'package:flutter_calandar_app/static/converter.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/common/attendance_dialog.dart';
import 'package:flutter_calandar_app/frontend/screens/common/logo_and_title.dart';
import 'package:flutter_calandar_app/backend/DB/handler/my_course_db.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/course_add_page.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/course_preview.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/ondemand_preview.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/timetable_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/todo_assist_files/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import "../../../backend/service/home_widget.dart";
import 'package:intl/intl.dart';

class TimeTablePage extends ConsumerStatefulWidget {
  void Function(int) moveToMoodlePage;
  TimeTablePage({required this.moveToMoodlePage, super.key});

  @override
  _TimeTablePageState createState() => _TimeTablePageState();
}

class _TimeTablePageState extends ConsumerState<TimeTablePage> {
  late int thisYear;
  late bool isScreenShotBeingTaken;
  final ScreenshotController _screenShotController = ScreenshotController();
  late Term currentQuarter;
  late Term currentSemester;
  late DateTime now;

  @override
  void initState() {
    super.initState();
    initTargetSem();
    now = DateTime.now();
    NextCourseHomeWidget().updateNextCourse(); // アプリ起動時にデータを更新
    isScreenShotBeingTaken = false;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String? userDepartment =
          SharepreferenceHandler().getValue(SharepreferenceKeys.userDepartment);

      if (userDepartment == null) {
        await showUserDepartmentSettingDialog(context);
      }
      await showAttendanceDialog(context, now, ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    ScrollController controller = ScrollController();
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      body: Container(
          decoration: BoxDecoration(color: BACKGROUND_COLOR),
          child: Scrollbar(
            controller: controller,
            interactive: true,
            radius: const Radius.circular(20),
            thumbVisibility: true,
            child: Padding(
              padding: EdgeInsets.only(
                left: SizeConfig.blockSizeHorizontal! * 0, //2.5
                right: SizeConfig.blockSizeHorizontal! * 0,
              ),
              child: ListView(
                primary: false,
                controller: controller,
                shrinkWrap: true,
                children: [
                  timeTable(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          )),
      floatingActionButton: Container(
          width: SizeConfig.blockSizeHorizontal! * 90,
          margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical! * 12),
          child: Row(children: [
            Expanded(
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ]),
                    child: buttonModel(() async {
                      await showMoodleRegisterGuide(
                          context, false, MoodleRegisterGuideType.timetable);
                      widget.moveToMoodlePage(4);
                    }, PALE_MAIN_COLOR, "自動取得", verticalpadding: 15))),
            const SizedBox(width: 10),
            FloatingActionButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CourseAddPage(
                          setTimetableState: setState,
                        );
                      });
                },
                backgroundColor: PALE_MAIN_COLOR,
                child: Icon(Icons.add, color: FORGROUND_COLOR)),
            const SizedBox(width: 10),
            timetableShareButton(context),
          ])),
    );
  }

  Widget timetableShareButton(BuildContext context) {
    return FloatingActionButton(
        heroTag: "timetable_2",
        backgroundColor: MAIN_COLOR,
        child: Icon(Icons.ios_share, color: FORGROUND_COLOR),
        onPressed: () async {
          setState(() {
            isScreenShotBeingTaken = true;
          });
          final screenshot = await _screenShotController.capture(
            delay: const Duration(milliseconds: 500),
          );
          setState(() {
            isScreenShotBeingTaken = false;
          });
          if (screenshot != null) {
            final shareFile = XFile.fromData(screenshot, mimeType: "image/png");

            await Share.shareXFiles([
              shareFile,
            ],
                sharePositionOrigin: Rect.fromLTWH(
                    0,
                    0,
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height / 2));
          }
        });
  }

  void initTargetSem() {
    DateTime now = DateTime.now();
    thisYear = Term.whenSchoolYear(now);
    Term? nowQuarter = Term.whenQuarter(now);
    Term? nowSemester = Term.whenSemester(now);

    if (nowQuarter != null) {
      currentQuarter = nowQuarter;
    } else {
      if (now.month <= 3) {
        currentQuarter = Term.winterQuarter;
      } else if (now.month <= 5) {
        currentQuarter = Term.springQuarter;
      } else if (now.month <= 7) {
        currentQuarter = Term.summerQuarter;
      } else if (now.month <= 11) {
        currentQuarter = Term.fallQuarter;
      } else {
        currentQuarter = Term.winterQuarter;
      }
    }
    if (nowSemester != null) {
      currentSemester = nowSemester;
    } else {
      if (now.month <= 3) {
        currentSemester = Term.fallSemester;
      } else if (now.month <= 7) {
        currentSemester = Term.springSemester;
      } else if (now.month <= 11) {
        currentSemester = Term.fallSemester;
      } else {
        currentSemester = Term.fallSemester;
      }
    }
  }

  void increasePgNumber() {
    if (currentQuarter == Term.fallQuarter ||
        currentQuarter == Term.winterQuarter) {
      thisYear += 1;
      currentQuarter = Term.springQuarter;
      currentSemester = Term.springSemester;
    } else {
      currentQuarter = Term.fallQuarter;
      currentSemester = Term.fallSemester;
    }
    setState(() {});
  }

  void decreasePgNumber() {
    if (currentQuarter == Term.springQuarter ||
        currentQuarter == Term.summerQuarter) {
      thisYear -= 1;
      currentQuarter = Term.fallQuarter;
      currentSemester = Term.fallSemester;
    } else {
      currentQuarter = Term.springQuarter;
      currentSemester = Term.springSemester;
    }
    setState(() {});
  }

  Widget springFallQuarterButton() {
    String quaterName;
    Color quaterColor;
    Term buttonQuarter;
    if (currentQuarter == Term.springQuarter ||
        currentQuarter == Term.summerQuarter) {
      quaterName = "   春   ";
      quaterColor = const Color.fromARGB(255, 255, 159, 191);
      buttonQuarter = Term.springQuarter;
    } else {
      quaterName = "   秋   ";
      quaterColor = const Color.fromARGB(255, 231, 85, 0);
      buttonQuarter = Term.fallQuarter;
    }
    return buttonModel(() {
      switchSemester();
    }, buttonColor(buttonQuarter, quaterColor), quaterName);
  }

  Widget summerWinterQuarterButton() {
    String quaterName;
    Color quaterColor;
    Term buttonQuarter;
    if (currentQuarter == Term.springQuarter ||
        currentQuarter == Term.summerQuarter) {
      quaterName = "   夏   ";
      quaterColor = Colors.blueAccent;
      buttonQuarter = Term.summerQuarter;
    } else {
      quaterName = "   冬   ";
      quaterColor = Colors.cyan;
      buttonQuarter = Term.winterQuarter;
    }
    return buttonModel(() {
      switchSemester();
    }, buttonColor(buttonQuarter, quaterColor), quaterName);
  }

  void switchSemester() {
    if (currentQuarter == Term.springQuarter) {
      setState(() {
        currentQuarter = Term.summerQuarter;
      });
    } else if (currentQuarter == Term.summerQuarter) {
      setState(() {
        currentQuarter = Term.springQuarter;
      });
    } else if (currentQuarter == Term.fallQuarter) {
      setState(() {
        currentQuarter = Term.winterQuarter;
      });
    } else if (currentQuarter == Term.winterQuarter) {
      setState(() {
        currentQuarter = Term.fallQuarter;
      });
    }
  }

  Color buttonColor(Term buttonQuarter, Color color) {
    if (currentQuarter == buttonQuarter) {
      return color;
    } else {
      return Colors.grey[350]!;
    }
  }

  Widget timeTable() {
    return Screenshot(
        controller: _screenShotController,
        child: Container(
            decoration: switchDecoration(),
            child: Column(children: [
              Row(children: [
                IconButton(
                    onPressed: () {
                      decreasePgNumber();
                    },
                    icon: const Icon(Icons.arrow_back_ios),
                    iconSize: 20,
                    color: BLUEGREY),
                Text(
                  "$thisYear年  ${currentSemester.text}",
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: BLUEGREY),
                ),
                IconButton(
                    onPressed: () {
                      setState(() {
                        increasePgNumber();
                      });
                    },
                    icon: const Icon(Icons.arrow_forward_ios),
                    iconSize: 20,
                    color: BLUEGREY),
                const Spacer(),
                doNotContainScreenShot(springFallQuarterButton()),
                doNotContainScreenShot(summerWinterQuarterButton()),
                showOnlyScreenShot(LogoAndTitle(size: 5)),
                const SizedBox(width: 40),
              ]),
              const SizedBox(height: 10),
              FutureBuilder(
                  future: MyCourseDatabaseHandler().getAllMyCourse(),
                  builder: ((context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return timeTableBody();
                    } else if (snapshot.hasError) {
                      return const SizedBox();
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      ref
                          .read(timeTableProvider)
                          .sortDataByWeekDay(snapshot.data!);
                      ref.read(timeTableProvider).initUniversityScheduleByDay(
                          thisYear,
                          [currentQuarter, currentSemester, Term.fullYear]);
                      return timeTableBody();
                    } else if (snapshot.data == null) {
                      ref.read(timeTableProvider).sortDataByWeekDay([]);
                      ref.read(timeTableProvider).initUniversityScheduleByDay(
                          thisYear,
                          [currentQuarter, currentSemester, Term.fullYear]);
                      return timeTableBody();
                    } else {
                      return noDataScreen();
                    }
                  })),
            ])));
  }

  BoxDecoration switchDecoration() {
    if (isScreenShotBeingTaken) {
      return BoxDecoration(color: BACKGROUND_COLOR);
    } else {
      return BoxDecoration(
        color: BACKGROUND_COLOR,
      );
    }
  }

  Widget doNotContainScreenShot(Widget target) {
    if (isScreenShotBeingTaken) {
      return const SizedBox();
    } else {
      return target;
    }
  }

  Widget showOnlyScreenShot(Widget target) {
    if (isScreenShotBeingTaken) {
      return target;
    } else {
      return const SizedBox();
    }
  }

  Widget noDataScreen() {
    return SizedBox(
        //height: SizeConfig.blockSizeVertical! * 80,
        width: SizeConfig.blockSizeHorizontal! * 85,
        child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(height: SizeConfig.blockSizeVertical! * 10),
          Image.asset('lib/assets/eye_catch/eyecatch.png',
              height: 200, width: 200),
          const SizedBox(height: 20),
          Text("時間割データはまだありません。",
              style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal! * 5,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.school, color: MAIN_COLOR),
                Text(" Moodle",
                    style: TextStyle(
                        color: MAIN_COLOR, fontWeight: FontWeight.bold)),
                Expanded(
                    child: Text(
                  " ページから、時間割データを取得しましょう！",
                  overflow: TextOverflow.clip,
                ))
              ]),
          const SizedBox(height: 30),
        ])));
  }

  Widget loadingScreen() {
    return SizedBox(
        height: SizeConfig.blockSizeVertical! * 80,
        width: SizeConfig.blockSizeHorizontal! * 95,
        child: const Center(child: CircularProgressIndicator()));
  }

  Widget timeTableBody() {
    return Column(children: [
      Row(children: [
        Expanded(child: generatePrirodColumn()),
        Column(children: [
          generateWeekThumbnail(),
          SizedBox(
              width: SizeConfig.blockSizeHorizontal! * cellWidth * 6,
              child: Row(children: [
                timetableSells(1),
                timetableSells(2),
                timetableSells(3),
                timetableSells(4),
                timetableSells(5),
                timetableSells(6),
              ]))
        ])
      ]),
      SizedBox(height: SizeConfig.blockSizeVertical! * 1),
      const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "   オンデマンド・その他",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700, color: BLUEGREY),
          )),
      SizedBox(
          height: SizeConfig.blockSizeVertical! * cellHeight,
          child: generateOndemandRow()),
      const Divider(height: 40),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: buttonModel(() {
            showAttendanceDialog(context, DateTime.now(), ref, true);
          }, Colors.blue, "今日の出欠記録", verticalpadding: 12.5)),
      const Divider(height: 40),
      SizedBox(
        height: SizeConfig.blockSizeVertical! * 3,
      )
    ]);
  }

  double cellWidth = 15.3;
  double cellHeight = 15;

  Widget generateWeekThumbnail() {
    List<String> days = ["月", "火", "水", "木", "金", "土"];
    return SizedBox(
        height: 20,
        child: ListView.builder(
          itemBuilder: (context, index) {
            Color bgColor = BACKGROUND_COLOR;
            Color fontColor = BLUEGREY;
            if (index + 1 == DateTime.now().weekday && index != 6) {
              bgColor = PALE_MAIN_COLOR;
              fontColor = FORGROUND_COLOR;
            }

            return Container(
                width: SizeConfig.blockSizeHorizontal! * cellWidth,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.5), color: bgColor),
                child: Center(
                    child: Text(
                  days.elementAt(index),
                  style:
                      TextStyle(color: fontColor, fontWeight: FontWeight.bold),
                )));
          },
          itemCount: 6,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
        ));
  }

  Widget generatePrirodColumn() {
    double fontSize = 8;

    return Column(children: [
      SizedBox(
        height: SizeConfig.blockSizeVertical! * 2.5,
      ),
      ListView.separated(
        itemBuilder: (context, index) {
          Color bgColor = BACKGROUND_COLOR;
          Color fontColor = BLUEGREY;
          DateTime now = DateTime.now();
          if (isBetween(now, Lesson.atPeriod(index + 1)!.start,
              Lesson.atPeriod(index + 1)!.end)) {
            bgColor = PALE_MAIN_COLOR;
            fontColor = FORGROUND_COLOR;
          }

          return Container(
              height: SizeConfig.blockSizeVertical! * cellHeight,
              decoration: BoxDecoration(
                  color: bgColor, borderRadius: BorderRadius.circular(2.5)),
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          DateFormat("HH:mm")
                              .format(Lesson.atPeriod(index + 1)!.start),
                          style: TextStyle(
                              color: fontColor,
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold),
                        ),
                        Text((index + 1).toString(),
                            style: TextStyle(
                                color: fontColor,
                                fontSize: fontSize * 2.2,
                                fontWeight: FontWeight.bold)),
                        Text(
                          DateFormat("HH:mm")
                              .format(Lesson.atPeriod(index + 1)!.end),
                          style: TextStyle(
                              color: fontColor,
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold),
                        ),
                      ])));
        },
        separatorBuilder: (context, index) {
          Widget resultinging = const SizedBox();
          DateTime now = DateTime.now();
          Color bgColor = BACKGROUND_COLOR;

          if (isBetween(now, Lesson.second.end, Lesson.third.start)) {
            bgColor = PALE_MAIN_COLOR;
          }
          if (index == 1) {
            resultinging = Container(
                height: SizeConfig.blockSizeVertical! * 2.5,
                color: bgColor,
                child: const Column(children: [
                  //Divider(color: Colors.grey, height: 0.5, thickness: 0.5),
                  Spacer(),
                  //Divider(color: Colors.grey, height: 0.5, thickness: 0.5)
                ]));
          }
          return resultinging;
        },
        itemCount: ref.read(timeTableProvider).maxPeriod,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      )
    ]);
  }

  Color cellBackGroundColor(int taskCount, Color color) {
    Color bgColor;
    if (taskCount <= 8) {
      bgColor = increaseRed(color, amount: 30 * taskCount);
    } else {
      bgColor = increaseRed(color, amount: 255);
    }
    return bgColor;
  }

  Color increaseRed(Color color, {int amount = 10}) {
    int red = color.red;
    int green = color.green;
    int blue = color.blue;

    red = (red + amount).clamp(0, 255); // clampで0～255の範囲に収める

    return Color.fromRGBO(red, green, blue, 1);
  }

  Widget timetableSells(int weekDay) {
    final tableData = ref.read(timeTableProvider);
    return SizedBox(
        width: SizeConfig.blockSizeHorizontal! * cellWidth,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: ref.read(timeTableProvider).maxPeriod,
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemBuilder: ((context, index) {
            Color bgColor = FORGROUND_COLOR;
            Widget cellContents = GestureDetector(onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CourseAddPage(
                      year: thisYear,
                      semester: currentSemester,
                      weekDay: DayOfWeek.weekAt(weekDay),
                      period: Lesson.atPeriod(index + 1),
                      setTimetableState: setState,
                    );
                  });
            });

            if (tableData.currentSemesterClasses.containsKey(weekDay) &&
                returnExistingPeriod(tableData.currentSemesterClasses[weekDay])
                    .contains(index + 1) &&
                tableData.currentSemesterClasses[weekDay].elementAt(
                        returnIndexFromPeriod(
                            tableData.currentSemesterClasses[weekDay],
                            index + 1))["year"] ==
                    thisYear) {
              if (tableData.currentSemesterClasses[weekDay].elementAt(
                          returnIndexFromPeriod(
                              tableData.currentSemesterClasses[weekDay],
                              index + 1))["semester"] ==
                      currentQuarter.value ||
                  tableData.currentSemesterClasses[weekDay].elementAt(
                          returnIndexFromPeriod(
                              tableData.currentSemesterClasses[weekDay],
                              index + 1))["semester"] ==
                      currentSemester.value ||
                  tableData.currentSemesterClasses[weekDay].elementAt(
                          returnIndexFromPeriod(
                              tableData.currentSemesterClasses[weekDay],
                              index + 1))["semester"] ==
                      "full_year") {
                cellContents = FutureBuilder(
                    future: TaskDatabaseHelper().getTaskListByCourseName(
                        tableData.currentSemesterClasses[weekDay].elementAt(
                            returnIndexFromPeriod(
                                tableData.currentSemesterClasses[weekDay],
                                index + 1))["courseName"]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return timeTableSellsChild(weekDay, index + 1, []);
                      } else if (snapshot.hasData) {
                        return timeTableSellsChild(
                            weekDay, index + 1, snapshot.data!);
                      } else {
                        return timeTableSellsChild(weekDay, index + 1, []);
                      }
                    });
              }
            }

            Color lineColor = BACKGROUND_COLOR;
            double lineWidth = 1;
            DateTime now = DateTime.now();

            if (isBetween(now, Lesson.atPeriod(index + 1)!.start,
                    Lesson.atPeriod(index + 1)!.end) &&
                now.weekday == weekDay &&
                weekDay <= 6) {
              lineWidth = 4;
              lineColor = PALE_MAIN_COLOR;
            }

            return Container(
                width: SizeConfig.blockSizeHorizontal! * cellWidth,
                height: SizeConfig.blockSizeVertical! * cellHeight,
                decoration: BoxDecoration(
                    color: bgColor,
                    border: Border.all(
                      color: lineColor,
                      width: lineWidth,
                    ),
                    borderRadius: BorderRadius.circular(4)),
                child: cellContents);
          }),
          separatorBuilder: (context, index) {
            Widget resultinging = const SizedBox();
            DateTime now = DateTime.now();
            Color bgColor = BACKGROUND_COLOR;
            Color fontColor = BLUEGREY;

            if (isBetween(now, Lesson.second.end, Lesson.third.start)) {
              bgColor = PALE_MAIN_COLOR;
              fontColor = Colors.white;
            }
            String childText = "";
            if (weekDay == 2) {
              childText = "昼";
            }
            if (weekDay == 3) {
              childText = "休";
            }
            if (weekDay == 4) {
              childText = "み";
            }

            if (index == 1) {
              resultinging = Container(
                  height: 25,
                  color: bgColor,
                  child: Column(children: [
                    const Spacer(),
                    Text(
                      childText,
                      style: TextStyle(
                          color: fontColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                  ]));
            }
            return resultinging;
          },
        ));
  }

  Widget generateOndemandRow() {
    final tableData = ref.read(timeTableProvider);
    int listLength = 0;
    if (tableData.sortedDataByWeekDay.containsKey(7)) {
      listLength = tableData.sortedDataByWeekDay[7].length;
    }

    return ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: listLength + 1,
        itemBuilder: (context, index) {
          Widget child = const SizedBox();
          if (index == listLength) {
            child = ondemandAddSell();
            return child;
          } else {
            if (tableData.sortedDataByWeekDay[7].elementAt(index)["semester"] ==
                    currentQuarter.value ||
                tableData.sortedDataByWeekDay[7].elementAt(index)["semester"] ==
                    "full_year" ||
                tableData.sortedDataByWeekDay[7].elementAt(index)["semester"] ==
                        currentSemester.value &&
                    tableData.sortedDataByWeekDay[7].elementAt(index)["year"] ==
                        thisYear) {
              child = Container(
                  height: SizeConfig.blockSizeVertical! * cellHeight,
                  width: SizeConfig.blockSizeHorizontal! * cellWidth,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: BACKGROUND_COLOR,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4)),
                  child: FutureBuilder(
                      future: TaskDatabaseHelper().getTaskListByCourseName(
                          tableData.sortedDataByWeekDay[7]
                              .elementAt(index)["courseName"]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ondemandSellsChild(index, []);
                        } else if (snapshot.hasData) {
                          return ondemandSellsChild(index, snapshot.data!);
                        } else {
                          return ondemandSellsChild(index, []);
                        }
                      }));
            }
            return child;
          }
        });
  }

  List<int> returnExistingPeriod(List<Map> target) {
    List<int> result = [];
    for (int i = 0; i < target.length; i++) {
      result.add(target.elementAt(i)["period"]);
    }
    return result;
  }

  int returnIndexFromPeriod(List<Map> target, int period) {
    int result = 0;
    for (int i = 0; i < target.length; i++) {
      if (target.elementAt(i)["period"] == period) {
        result = i;
      }
    }
    return result;
  }

  Widget timeTableSellsChild(
      int weekDay, int period, List<Map<String, dynamic>> taskList) {
    double fontSize = 12;
    final timeTableData = ref.read(timeTableProvider);
    Color bgColor = hexToColor(timeTableData.currentSemesterClasses[weekDay]
        .elementAt(returnIndexFromPeriod(
            timeTableData.currentSemesterClasses[weekDay], period))["color"]);
    Map targetData = timeTableData.currentSemesterClasses[weekDay].elementAt(
        returnIndexFromPeriod(
            timeTableData.currentSemesterClasses[weekDay], period));
    String className = timeTableData.currentSemesterClasses[weekDay].elementAt(
        returnIndexFromPeriod(timeTableData.currentSemesterClasses[weekDay],
            period))["courseName"];
    String? classRoom = timeTableData.currentSemesterClasses[weekDay].elementAt(
        returnIndexFromPeriod(timeTableData.currentSemesterClasses[weekDay],
            period))["classRoom"];
    int taskLength = taskList.length;

    Widget classRoomView = const SizedBox();
    if (classRoom != null && classRoom != "" && classRoom != "-") {
      classRoomView = Container(
          decoration: BoxDecoration(
              color: FORGROUND_COLOR,
              borderRadius: const BorderRadius.all(Radius.circular(2))),
          child: Text(
            classRoom,
            style: const TextStyle(
              fontSize: 10,
            ),
            overflow: TextOverflow.visible,
            maxLines: 2,
          ));
    }

    return Stack(children: [
      Container(
          width: SizeConfig.blockSizeHorizontal! * cellWidth,
          decoration: BoxDecoration(
              color: cellBackGroundColor(taskLength, bgColor).withOpacity(0.7),
              borderRadius: BorderRadius.circular(2)),
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CoursePreview(
                        target: targetData,
                        setTimetableState: setState,
                        taskList: taskList,
                      );
                    });
              },
              child: Column(children: [
                SizedBox(height: SizeConfig.blockSizeVertical! * 2.25),
                Expanded(
                    child: Center(
                        child: Text(
                  className,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                      overflow: TextOverflow.ellipsis),
                  maxLines: 4,
                ))),
                classRoomView,
                const SizedBox(height: 10),
              ]))),
      doNotContainScreenShot(Align(
          alignment: const Alignment(1, -1),
          child: absentBadgeBuilder(targetData))),
      doNotContainScreenShot(Align(
          alignment: const Alignment(-1, -1),
          child: lengthBadge(taskLength, fontSize, true))),
    ]);
  }

  Widget absentBadgeBuilder(Map targetData) {
    int myCourseID = targetData["id"];
    int remainAbsent = targetData["remainAbsent"] ?? 0;
    return FutureBuilder(
        future: MyCourseDatabaseHandler().getAttendanceRecordFromDB(myCourseID),
        builder: (context, snapShot) {
          if (snapShot.connectionState == ConnectionState.done) {
            if (snapShot.hasData && snapShot.data!.isNotEmpty) {
              int count = 0;

              for (int i = 0; i < snapShot.data!.length; i++) {
                if (snapShot.data!.elementAt(i)["attendStatus"] == "absent") {
                  count += 1;
                }
              }
              return absentBadge(count, remainAbsent);
            } else {
              return const SizedBox();
            }
          } else {
            return const SizedBox();
          }
        });
  }

  Widget absentBadge(int absentNum, int remainAbsent) {
    if (absentNum == 0) {
      return Container(
        decoration: const BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5))),
        child: Text(
          " 無欠席 ",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: SizeConfig.blockSizeVertical! * cellHeight / 12,
              color: Colors.white),
        ),
      );
    } else {
      Color backGroundColor = BLUEGREY;
      if (absentNum >= remainAbsent) {
        backGroundColor = Colors.redAccent;
      }
      return Container(
        decoration: BoxDecoration(
            color: backGroundColor,
            borderRadius:
                const BorderRadius.only(bottomLeft: Radius.circular(5))),
        child: Text(
          " 欠席 " + absentNum.toString() + "/" + remainAbsent.toString(),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: SizeConfig.blockSizeVertical! * cellHeight / 12,
              color: Colors.white),
        ),
      );
    }
  }

  Widget ondemandSellsChild(int index, List<Map<String, dynamic>> taskList) {
    final tableData = ref.read(timeTableProvider);
    Map target = tableData.sortedDataByWeekDay[7].elementAt(index);
    double fontSize = 11;
    String className = target["courseName"];
    int taskLength = taskList.length;

    Color colorning =
        hexToColor(tableData.sortedDataByWeekDay[7].elementAt(index)["color"]);
    Color bgColor = cellBackGroundColor(taskLength, colorning).withOpacity(0.7);

    return GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return OndemandPreview(
                  target: target,
                  setTimetableState: setState,
                  taskList: taskList,
                );
              });
        },
        child: Stack(children: [
          Container(
            decoration: BoxDecoration(
                color: bgColor, borderRadius: BorderRadius.circular(2)),
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              SizedBox(height: SizeConfig.blockSizeVertical! * 2.25),
              Expanded(
                  child: Center(
                child: Text(className,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize,
                        overflow: TextOverflow.ellipsis),
                    maxLines: 4),
              ))
            ]),
          ),
          doNotContainScreenShot(Align(
              alignment: const Alignment(-1, -1),
              child: lengthBadge(taskLength, fontSize, true)))
        ]));
  }

  Widget ondemandAddSell() {
    Color bgColor = FORGROUND_COLOR;
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CourseAddPage(
                setTimetableState: setState,
              );
            });
      },
      child: Container(
          height: SizeConfig.blockSizeVertical! * cellHeight,
          width: SizeConfig.blockSizeHorizontal! * cellWidth,
          decoration: BoxDecoration(
              color: bgColor, borderRadius: BorderRadius.circular(2)),
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: const Center(
              child: Icon(Icons.add_rounded, size: 30, color: Colors.grey))),
    );
  }

  Color hexToColor(String hexColor) {
    // 16進数のカラーコードが#で始まる場合、#を削除する
    if (hexColor.startsWith('#')) {
      hexColor = hexColor.substring(1);
    }

    // 16進数のカラーコードをRGBに分解する
    int hexValue = int.parse(hexColor, radix: 16);
    int alpha = (hexValue >> 24) & 0xFF;
    int red = (hexValue >> 16) & 0xFF;
    int green = (hexValue >> 8) & 0xFF;
    int blue = hexValue & 0xFF;

    // Colorオブジェクトを作成して返す
    return Color.fromARGB(alpha, red, green, blue);
  }
}
