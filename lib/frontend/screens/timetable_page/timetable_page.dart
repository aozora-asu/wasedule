import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/converter.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
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
import "../../../backend/home_widget.dart";

class TimeTablePage extends ConsumerStatefulWidget {
  const TimeTablePage({super.key});

  @override
  _TimeTablePageState createState() => _TimeTablePageState();
}

class _TimeTablePageState extends ConsumerState<TimeTablePage> {
  late int thisYear;
  late int semesterNum;
  late String targetSemester;
  late bool isScreenShotBeingTaken;
  final ScreenshotController _screenShotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    initTargetSem();
    NextCourseHomeWidget().updateNextCourse(); // アプリ起動時にデータを更新
    isScreenShotBeingTaken = false;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    ScrollController controller = ScrollController();
    return Scaffold(
      body: Container(
          decoration:const BoxDecoration(
              color:BACKGROUND_COLOR
          ),
          child: Scrollbar(
            controller: controller,
            interactive: true,
            radius: const Radius.circular(20),
            thumbVisibility: true,
            child: Padding(
              padding: EdgeInsets.only(
                left: SizeConfig.blockSizeHorizontal! * 0,//2.5
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
          margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical! * 12),
          child: Row(children: [
            const Spacer(),
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
                child: const Icon(Icons.add, color: WHITE)),
            const SizedBox(width: 10),
            timetableShareButton(context),
          ])),
    );
  }

  Widget timetableShareButton(BuildContext context) {
    return FloatingActionButton(
        heroTag: "timetable_2",
        backgroundColor: MAIN_COLOR,
        child: const Icon(Icons.ios_share, color: WHITE),
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
    thisYear = datetime2schoolYear(now);
    List semesterList = datetime2termList(now);

    semesterNum = 0;
    if (now.month <= 3) {
      semesterNum = 4;
    } else if (now.month <= 5) {
      semesterNum = 1;
    } else if (now.month <= 9) {
      semesterNum = 2;
    } else if (now.month <= 11) {
      semesterNum = 3;
    } else {
      semesterNum = 4;
    }

    if (semesterList.isNotEmpty) {
      String quarter = semesterList[1];
      if (quarter == "spring_quarter") {
        semesterNum = 1;
      } else if (quarter == "summer_quarter") {
        semesterNum = 2;
      } else if (quarter == "fall_quarter") {
        semesterNum = 3;
      } else if (quarter == "winter_quarter") {
        semesterNum = 4;
      }
    }
    targetSemester = "$thisYear-$semesterNum";
  }

  void increasePgNumber() {
    if (semesterNum == 3 || semesterNum == 4) {
      thisYear += 1;
      semesterNum = 1;
    } else {
      semesterNum = 3;
    }
    setState(() {
      targetSemester = "$thisYear-$semesterNum";
    });
  }

  void decreasePgNumber() {
    if (semesterNum == 1 || semesterNum == 2) {
      thisYear -= 1;
      semesterNum = 3;
    } else {
      semesterNum = 1;
    }
    setState(() {
      targetSemester = "$thisYear-$semesterNum";
    });
  }

  Widget changeQuaterbutton(int type) {
    int buttonSemester = 0;
    if (type == 1) {
      buttonSemester = button1Semester();
    } else {
      buttonSemester = button2Semester();
    }

    String quaterName = "";
    switch (buttonSemester) {
      case 1:
        quaterName = "   春   ";
      case 2:
        quaterName = "   夏   ";
      case 3:
        quaterName = "   秋   ";
      case 4:
        quaterName = "   冬   ";
    }

    Color quaterColor = WHITE;
    switch (buttonSemester) {
      case 1:
        quaterColor = const Color.fromARGB(255, 255, 159, 191);
      case 2:
        quaterColor = Colors.blueAccent;
      case 3:
        quaterColor = const Color.fromARGB(255, 231, 85, 0);
      case 4:
        quaterColor = Colors.cyan;
    }

    return buttonModel(() {
      switchSemester();
    }, buttonColor(buttonSemester, quaterColor), quaterName);
  }

  void switchSemester() {
    if (semesterNum == 1) {
      setState(() {
        semesterNum = 2;
      });
    } else if (semesterNum == 2) {
      setState(() {
        semesterNum = 1;
      });
    } else if (semesterNum == 3) {
      setState(() {
        semesterNum = 4;
      });
    } else if (semesterNum == 4) {
      setState(() {
        semesterNum = 3;
      });
    }
  }

  int button1Semester() {
    if (semesterNum == 1) {
      return 1;
    } else if (semesterNum == 2) {
      return 1;
    } else if (semesterNum == 3) {
      return 3;
    } else {
      return 3;
    }
  }

  int button2Semester() {
    if (semesterNum == 1) {
      return 2;
    } else if (semesterNum == 2) {
      return 2;
    } else if (semesterNum == 3) {
      return 4;
    } else {
      return 4;
    }
  }

  Color buttonColor(int buttonSemester, Color color) {
    if (semesterNum == buttonSemester) {
      return color;
    } else {
      return Colors.grey[350]!;
    }
  }

  String semesterText() {
    String result = "年  春学期";
    if (semesterNum == 2) {
      result = "年  春学期";
    } else if (semesterNum == 3) {
      result = "年  秋学期";
    } else if (semesterNum == 4) {
      result = "年  秋学期";
    }
    return thisYear.toString() + result;
  }

  String currentQuaterID() {
    String result = "full_year";
    if (semesterNum == 1) {
      result = "spring_quarter";
    } else if (semesterNum == 2) {
      result = "summer_quarter";
    } else if (semesterNum == 3) {
      result = "fall_quarter";
    } else if (semesterNum == 4) {
      result = "winter_quarter";
    }
    return result;
  }

  String currentSemesterID() {
    String result = "full_year";
    if (semesterNum == 1 || semesterNum == 2) {
      result = "spring_semester";
    } else if (semesterNum == 3 || semesterNum == 4) {
      result = "fall_semester";
    }
    return result;
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
                    color:BLUEGREY),
                Text(
                  semesterText(),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color:BLUEGREY
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
                    color:BLUEGREY),
                const Spacer(),
                doNotContainScreenShot(changeQuaterbutton(1)),
                doNotContainScreenShot(changeQuaterbutton(2)),
                showOnlyScreenShot(LogoAndTitle(size: 5)),
                const Spacer(),
              ]),
              const SizedBox(height:10),
              FutureBuilder(
                  future: MyCourseDatabaseHandler().getMyCourse(),
                  builder: ((context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return timeTableBody();
                    } else if (snapshot.hasError) {
                      return const SizedBox();
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      ref
                          .read(timeTableProvider)
                          .sortDataByWeekDay(snapshot.data!);
                      ref
                          .read(timeTableProvider)
                          .initUniversityScheduleByDay(thisYear, semesterNum);
                      for (int i = 0; i < snapshot.data!.length; i++) {}
                      for (int i = 0;
                          i <
                              ref
                                  .read(timeTableProvider)
                                  .sortedDataByWeekDay
                                  .length;
                          i++) {}
                      return timeTableBody();
                    } else {
                      return noDataScreen();
                    }
                  }))
            ])));
  }

  BoxDecoration switchDecoration() {
    if (isScreenShotBeingTaken) {
      return const BoxDecoration(color: BACKGROUND_COLOR);
    } else {
      return const BoxDecoration(
        color:BACKGROUND_COLOR,
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
        height: SizeConfig.blockSizeVertical! * 80,
        width: SizeConfig.blockSizeHorizontal! * 85,
        child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                  " ページから、時間割データを自動作成しましょう！",
                  overflow: TextOverflow.clip,
                ))
              ]),
          const Icon(
            Icons.keyboard_double_arrow_right,
            color: MAIN_COLOR,
            size: 150,
          ),
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
              fontSize: 17.5,
              fontWeight: FontWeight.w700,
              color:BLUEGREY
            ),
          )),
      SizedBox(
          height: SizeConfig.blockSizeVertical! * cellHeight,
          child: generateOndemandRow()),
      SizedBox(
        height: SizeConfig.blockSizeVertical! * 3,
      )
    ]);
  }

  double cellWidth = 15.3;
  double cellHeight = 14;

  Widget generateWeekThumbnail() {
    List<String> days = ["月", "火", "水", "木", "金", "土"];
    return SizedBox(
        height: SizeConfig.blockSizeVertical! * 2.5,
        child: ListView.builder(
          itemBuilder: (context, index) {
            Color bgColor = BACKGROUND_COLOR;
            Color fontColor = BLUEGREY;
            if (index + 1 == DateTime.now().weekday && index != 6) {
              bgColor = MAIN_COLOR;
              fontColor = WHITE;
            }

            return Container(
                width: SizeConfig.blockSizeHorizontal! * cellWidth,
                height: SizeConfig.blockSizeVertical! * 2,
                decoration:BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: bgColor),
                child: Center(
                    child: Text(
                  days.elementAt(index),
                  style: TextStyle(
                    color: fontColor,
                    fontWeight:FontWeight.bold),
                )));
          },
          itemCount: 6,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
        ));
  }

  Widget generatePrirodColumn() {
    double fontSize = SizeConfig.blockSizeHorizontal! * 2;

    return Column(children: [
      SizedBox(
        height: SizeConfig.blockSizeVertical! * 2.5,
      ),
      ListView.separated(
        itemBuilder: (context, index) {
          Color bgColor = BACKGROUND_COLOR;
          Color fontColor = BLUEGREY;
          DateTime now = DateTime.now();
          if (returnBeginningDateTime(index + 1).isBefore(now) &&
              returnEndDateTime(index + 1).isAfter(now)) {
            bgColor = MAIN_COLOR;
            fontColor = WHITE;
          }

          return Container(
              height: SizeConfig.blockSizeVertical! * cellHeight,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(5)
              ),
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          returnBeginningTime(index + 1),
                          style:
                              TextStyle(
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
                          returnEndTime(index + 1),
                          style:
                              TextStyle(
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
          if (returnEndDateTime(2).isBefore(now) &&
              returnBeginningDateTime(3).isAfter(now)) {
            bgColor = MAIN_COLOR;
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

  Color cellBackGroundColor(int length, Color color) {
    Color bgColor = WHITE;
    switch (length) {
      case 0:
        bgColor = increaseRed(color, amount: 0);
      case 1:
        bgColor = increaseRed(color, amount: 30);
      case 2:
        bgColor = increaseRed(color, amount: 60);
      case 3:
        bgColor = increaseRed(color, amount: 90);
      case 4:
        bgColor = increaseRed(color, amount: 120);
      case 5:
        bgColor = increaseRed(color, amount: 150);
      case 6:
        bgColor = increaseRed(color, amount: 180);
      case 7:
        bgColor = increaseRed(color, amount: 210);
      case 8:
        bgColor = increaseRed(color, amount: 240);
      case 9:
        bgColor = increaseRed(color, amount: 255);
      default:
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
            Color bgColor = WHITE;
            Widget cellContents = GestureDetector(onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CourseAddPage(
                      year: thisYear,
                      semester: currentSemesterID(),
                      weekDay: weekDay,
                      period: index + 1,
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
                      currentQuaterID() ||

                  tableData.currentSemesterClasses[weekDay].elementAt(
                          returnIndexFromPeriod(
                              tableData.currentSemesterClasses[weekDay],
                              index + 1))["semester"] ==
                      currentSemesterID() ||

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
            if (returnBeginningDateTime(index + 1).isBefore(now) &&
                returnEndDateTime(index + 1).isAfter(now) &&
                now.weekday == weekDay &&
                weekDay <= 6) {
              lineWidth = 4;
              lineColor = MAIN_COLOR;
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
                  borderRadius: BorderRadius.circular(4)
                ),
                child: cellContents);
          }),
          separatorBuilder: (context, index) {
            Widget resultinging = const SizedBox();
            DateTime now = DateTime.now();
            Color bgColor = BACKGROUND_COLOR;
            if (returnEndDateTime(2).isBefore(now) &&
                returnBeginningDateTime(3).isAfter(now)) {
              bgColor = MAIN_COLOR;
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
                  height: SizeConfig.blockSizeVertical! * 2.5,
                  color: bgColor,
                  child: Column(children: [
                    const Spacer(),
                    Text(childText,
                        style: TextStyle(
                            color: BLUEGREY,
                            fontSize: SizeConfig.blockSizeHorizontal! * 3,
                            fontWeight:FontWeight.bold),),
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
          if(index == listLength ){
            child = ondemandAddSell();
            return child;
          }else{
            if (tableData.sortedDataByWeekDay[7].elementAt(index)["semester"] ==
                    currentQuaterID() ||
                tableData.sortedDataByWeekDay[7].elementAt(index)["semester"] ==
                    "full_year" ||
                tableData.sortedDataByWeekDay[7].elementAt(index)["semester"] ==
                        currentSemesterID() &&
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
                    borderRadius: BorderRadius.circular(4)
                  ),
                  child: FutureBuilder(
                      future: TaskDatabaseHelper().getTaskListByCourseName(
                          tableData.sortedDataByWeekDay[7]
                              .elementAt(index)["courseName"]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
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
    double fontSize = SizeConfig.blockSizeHorizontal! * 2.75;
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
          decoration:const  BoxDecoration(
              color: WHITE,
              borderRadius: BorderRadius.all(Radius.circular(2))),
          child: Text(
            classRoom,
            style: TextStyle(
              fontSize: SizeConfig.blockSizeHorizontal! * 2.5,
            ),
            overflow: TextOverflow.visible,
            maxLines: 2,
          ));
    }

    return Stack(children: [
      Container(
          width: SizeConfig.blockSizeHorizontal! * cellWidth,
          decoration:BoxDecoration(
            color: cellBackGroundColor(taskLength, bgColor).withOpacity(0.7),
            borderRadius: BorderRadius.circular(2)
            ),
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
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                SizedBox(height: SizeConfig.blockSizeVertical! * 2.25),
                const Spacer(),
                Text(
                  className,
                  style: TextStyle(
                      fontSize: fontSize, overflow: TextOverflow.ellipsis),
                  maxLines: 4,
                ),
                const Spacer(),
                classRoomView,
                const Spacer()
              ]))),
      doNotContainScreenShot(Align(
          alignment: const Alignment(-1, -1),
          child: lengthBadge(taskLength, fontSize, true))),
    ]);
  }

  Widget ondemandSellsChild(int index, List<Map<String, dynamic>> taskList) {
    final tableData = ref.read(timeTableProvider);
    Map target = tableData.sortedDataByWeekDay[7].elementAt(index);
    double fontSize = SizeConfig.blockSizeHorizontal! * 2.75;
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
            decoration:BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(2)
            ),
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              SizedBox(height: SizeConfig.blockSizeVertical! * 2.25),
              const Spacer(),
              Text(
                className,
                style: TextStyle(
                    fontSize: fontSize, overflow: TextOverflow.ellipsis),
                maxLines: 4,
              ),
              const Spacer(),
            ]),
          ),
          doNotContainScreenShot(Align(
              alignment: const Alignment(-1, -1),
              child: lengthBadge(taskLength, fontSize, true)))
        ]));
  }


  Widget ondemandAddSell() {
    Color bgColor = WHITE;
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
        child:
          Container(
            height: SizeConfig.blockSizeVertical! * cellHeight,
            width: SizeConfig.blockSizeHorizontal! * cellWidth,
            decoration:BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(2)
            ),
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child:const Center(
              child:Icon(
                Icons.add_rounded,
                size:30,
                color:Colors.grey
              ))
          ),
        );
  }

  AssetImage tableBackGroundImage() {
    if (DateTime.now().hour >= 5 && DateTime.now().hour <= 9) {
      return const AssetImage(
          'lib/assets/calendar_background/ookuma_morning.png');
    } else if (DateTime.now().hour >= 9 && DateTime.now().hour <= 17) {
      return const AssetImage('lib/assets/calendar_background/ookuma_day.png');
    } else {
      return const AssetImage(
          'lib/assets/calendar_background/ookuma_night.png');
    }
  }

  String returnBeginningTime(int period) {
    switch (period) {
      case 1:
        return "08:50";
      case 2:
        return "10:40";
      case 3:
        return "13:10";
      case 4:
        return "15:05";
      case 5:
        return "17:00";
      case 6:
        return "18:55";
      default:
        return "20:45";
    }
  }

  DateTime returnBeginningDateTime(int period) {
    DateTime now = DateTime.now();
    switch (period) {
      case 1:
        return DateTime(now.year, now.month, now.day, 8, 50);
      case 2:
        return DateTime(now.year, now.month, now.day, 10, 40);
      case 3:
        return DateTime(now.year, now.month, now.day, 13, 10);
      case 4:
        return DateTime(now.year, now.month, now.day, 15, 05);
      case 5:
        return DateTime(now.year, now.month, now.day, 17, 00);
      case 6:
        return DateTime(now.year, now.month, now.day, 18, 55);
      default:
        return DateTime(now.year, now.month, now.day, 20, 45);
    }
  }

  String returnEndTime(int period) {
    switch (period) {
      case 1:
        return "10:30";
      case 2:
        return "12:20";
      case 3:
        return "14:50";
      case 4:
        return "16:45";
      case 5:
        return "18:40";
      case 6:
        return "20:35";
      default:
        return "21:35";
    }
  }

  DateTime returnEndDateTime(int period) {
    DateTime now = DateTime.now();
    switch (period) {
      case 1:
        return DateTime(now.year, now.month, now.day, 10, 30);
      case 2:
        return DateTime(now.year, now.month, now.day, 12, 20);
      case 3:
        return DateTime(now.year, now.month, now.day, 14, 50);
      case 4:
        return DateTime(now.year, now.month, now.day, 16, 45);
      case 5:
        return DateTime(now.year, now.month, now.day, 18, 40);
      case 6:
        return DateTime(now.year, now.month, now.day, 20, 35);
      default:
        return DateTime(now.year, now.month, now.day, 21, 35);
    }
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
