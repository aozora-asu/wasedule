import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/sharepreference.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/code_share_page.dart';
import 'package:flutter_calandar_app/frontend/screens/common/tutorials.dart';
import 'package:flutter_calandar_app/frontend/screens/setting_page/timetable_setting.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/credit/requiredcredits_stats.dart';
import 'package:flutter_calandar_app/static/constant.dart';
import 'package:flutter_calandar_app/static/converter.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/screens/common/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/common/attendance_dialog.dart';
import 'package:flutter_calandar_app/frontend/screens/common/logo_and_title.dart';
import 'package:flutter_calandar_app/backend/DB/handler/my_course_db.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/timetable/course_add_page.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/timetable/course_preview.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/timetable/timetable_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/todo_assist_files/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import "../../../../backend/service/home_widget.dart";
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
  final ScrollController pageScrollController = ScrollController();
  late Term currentQuarter;
  late Term currentSemester;
  late DateTime now;

  late int selectedCreditsSum;
  late bool isSelectedlistGenerated;
  late List<bool> isSelectedList;

  late bool isShowSaturday;
  late bool isOndemandTableSide;

  bool _isFabVisible = true;

  late double tableRowLength;
  late double cellWidth;
  double cellHeight = 11.5;
  double cellsRadius = 5.0;
  double separatorHeight = 0;

  @override
  void initState() {
    super.initState();
    initTargetSem();
    now = DateTime.now();
    //NextCourseHomeWidget().updateNextCourse(); // アプリ起動時にデータを更新
    isScreenShotBeingTaken = false;

    selectedCreditsSum = 0;
    isSelectedlistGenerated = false;
    isSelectedList = [];

    pageScrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String? userDepartment =
          SharepreferenceHandler().getValue(SharepreferenceKeys.userDepartment);

      if (userDepartment == null && mounted) {
        await showUserDepartmentSettingDialog(context);
      } else if (mounted) {
        await showAttendanceDialog(context, now, ref);
      }
    });
  }

  void initCellWidth() {
    tableRowLength = 5;

    if (isShowSaturday) {
      tableRowLength += 1;
    }
    if (isOndemandTableSide) {
      tableRowLength += 1;
    }

    switch (tableRowLength) {
      case 5:
        cellWidth = 18.35;
        break;
      case 6:
        cellWidth = 15.25;
        break;
      case 7:
        cellWidth = 13.15;
        break;
      default:
        cellWidth = 15;
        break;
    }

    setState(() {});
  }

  void _onScroll() {
    // スクロールの方向に応じてFABを表示・非表示にする
    if (pageScrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      // 下方向にスクロールした場合
      if (_isFabVisible) {
        setState(() {
          _isFabVisible = false; // FABを非表示
        });
      }
    } else if (pageScrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      // 上方向にスクロールした場合
      if (!_isFabVisible) {
        setState(() {
          _isFabVisible = true; // FABを表示
        });
      }
    }
  }

  BoxDecoration floatingButtonDecorartion =
      BoxDecoration(borderRadius: BorderRadius.circular(30), boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      spreadRadius: 2,
      blurRadius: 5,
      offset: const Offset(0, 3),
    ),
  ]);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    isShowSaturday =
        SharepreferenceHandler().getValue(SharepreferenceKeys.isShowSaturday);
    isOndemandTableSide = SharepreferenceHandler()
        .getValue(SharepreferenceKeys.isOndemandTableSide);

    initCellWidth();

    return Scaffold(
        backgroundColor: BACKGROUND_COLOR,
        body: CustomScrollView(
            controller: pageScrollController,
            slivers: <Widget>[
              SliverAppBar(
                // ピン留めオプション。true にすると AppBar はスクロールで画面上に固定される
                floating: true,
                pinned: false,
                snap: false,
                collapsedHeight: 80,
                expandedHeight: 80,
                // AppBar の拡張部分 (スクロール時に表示される)
                flexibleSpace: pageHeader(),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Column(
                        children: [timeTable(), const SizedBox(height: 100)]);
                  },
                  // リストアイテムの数
                  childCount: 1,
                ),
              ),
            ]),
        floatingActionButton: AnimatedOpacity(
          opacity: _isFabVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 600),
          child: timetableShareButton(context),
        ));
  }

  Widget timetableShareButton(BuildContext context) {
    return FloatingActionButton(
        heroTag: "timetable_2",
        backgroundColor: MAIN_COLOR,
        child: Icon(CupertinoIcons.camera, color: FORGROUND_COLOR),
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

  int initMaxPeriod() {
    int maxPeriod = SharepreferenceHandler()
        .getValue(SharepreferenceKeys.tableColumnLength);

    final tableData = ref.read(timeTableProvider);
    for (int weekDay = 1; weekDay < 7; weekDay++) {
      List<MyCourse> dailyList =
          tableData.currentSemesterClasses[weekDay] ?? [];

      for (var course in dailyList) {
        if (course.period != null) {
          if (course.period!.period > maxPeriod) {
            maxPeriod = course.period!.period;
          }
        }
      }
    }
    return maxPeriod;
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
      quaterColor = BLUEGREY; //const Color.fromARGB(255, 255, 159, 191);
      buttonQuarter = Term.springQuarter;
    } else {
      quaterName = "   秋   ";
      quaterColor = BLUEGREY; //const Color.fromARGB(255, 231, 85, 0);
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
      quaterColor = BLUEGREY; //Colors.blueAccent;
      buttonQuarter = Term.summerQuarter;
    } else {
      quaterName = "   冬   ";
      quaterColor = BLUEGREY; //Colors.cyan;
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

  Widget pageHeader() {
    return Container(
        decoration: BoxDecoration(color: FORGROUND_COLOR, boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 2,
            offset: const Offset(0, 0),
          ),
        ]),
        child: Column(children: [
          Row(children: [
            IconButton(
                onPressed: () {
                  setState(() {
                    isSelectedlistGenerated = false;
                    decreasePgNumber();
                  });
                },
                icon: const Icon(Icons.arrow_back_ios),
                iconSize: 20,
                color: BLUEGREY),
            Text(
              "$thisYear年  ${currentSemester.text}",
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w700, color: BLUEGREY),
            ),
            IconButton(
                onPressed: () {
                  setState(() {
                    isSelectedlistGenerated = false;
                    increasePgNumber();
                  });
                },
                icon: const Icon(Icons.arrow_forward_ios),
                iconSize: 20,
                color: BLUEGREY),
            const Spacer(),
            doNotContainScreenShot(springFallQuarterButton()),
            doNotContainScreenShot(summerWinterQuarterButton()),
            const SizedBox(width: 7.5),
          ]),
          doNotContainScreenShot(Row(children: [
            const SizedBox(width: 5),
            simpleSmallButton("今日の出欠", () async {
              await showAttendanceDialog(context, DateTime.now(), ref, true);
            }),
            simpleSmallButton("授業の自動取得", () async {
              await selectCourseFetchModeDialog(context, () {
                widget.moveToMoodlePage(4);
              });
            }),
            const Spacer(),
          ])),
        ]));
  }

  Future<List<MyCourse>?> loadData() async {
    await ref.read(timeTableProvider).getData();
    List<MyCourse>? result = await MyCourse.getAllMyCourse();
    return result;
  }

  Widget timeTable() {
    return Screenshot(
        controller: _screenShotController,
        child: Container(
            decoration: switchDecoration(),
            child: Column(children: [
              FutureBuilder(
                  future: loadData(),
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
    double _cellWidth = cellWidth;
    double _tableRowLength = tableRowLength;
    int maxPeriod = initMaxPeriod();

    return Column(children: [
      showOnlyScreenShot(Container(
          color: MAIN_COLOR,
          child: Row(children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: LogoAndTitle(
                    size: 5,
                    isLogoWhite: true,
                    color: Colors.white,
                    logotype: AppLogoType.timetable)),
            const Spacer(),
            Text(
              "$thisYear年  ${currentSemester.text}・${currentQuarter.text}",
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
            const SizedBox(width: 15),
          ]))),
      showOnlyScreenShot(const Divider(
          height: 3,
          thickness: 3,
          color: PALE_MAIN_COLOR,
          indent: 0,
          endIndent: 0)),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        generatePerirodColumn(maxPeriod),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          doNotContainScreenShot(const SizedBox(height: 5)),
          generateWeekThumbnail(),
          SizedBox(
              width: SizeConfig.blockSizeHorizontal! *
                  _cellWidth *
                  _tableRowLength,
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                timetableCells(1, maxPeriod),
                timetableCells(2, maxPeriod),
                timetableCells(3, maxPeriod),
                timetableCells(4, maxPeriod),
                timetableCells(5, maxPeriod),
                if (isShowSaturday) timetableCells(6, maxPeriod),
                if (isOndemandTableSide) generateOndemandColumn()
              ])),
          const SizedBox(height: 10),
        ])
      ]),
      if (!isOndemandTableSide)
        const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "   オンデマンド・その他",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, color: BLUEGREY),
            )),
      if (!isOndemandTableSide)
        SizedBox(
            height: SizeConfig.blockSizeVertical! * cellHeight,
            child: generateOndemandRow()),
      doNotContainScreenShot(Column(children: [
        if (!isOndemandTableSide) const SizedBox(height: 30),
        Row(children: [
          const Text("   登録単位数",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, color: BLUEGREY)),
          const Spacer(),
          if (selectedCreditsSum != 0)
            const Text("選択中の単位数合計： ", style: TextStyle(color: Colors.grey)),
          if (selectedCreditsSum != 0)
            Text(selectedCreditsSum.toString(),
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          const SizedBox(width: 15)
        ]),
        timetableCreditsView(),
        SizedBox(
          height: SizeConfig.blockSizeVertical! * 3,
        )
      ]))
    ]);
  }

  Widget generateWeekThumbnail() {
    List<String> days = ["月", "火", "水", "木", "金"];
    if (isShowSaturday) {
      days.add("土");
    }
    if (isOndemandTableSide) {
      days.add("OD他");
    }
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
                    borderRadius: BorderRadius.circular(cellsRadius / 2),
                    color: bgColor),
                child: Center(
                    child: Text(
                  days.elementAt(index),
                  style:
                      TextStyle(color: fontColor, fontWeight: FontWeight.bold),
                )));
          },
          itemCount: days.length,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
        ));
  }

  Widget generatePerirodColumn(int maxPeriod) {
    double fontSize = 7.5;

    return Expanded(
        child: Column(children: [
      SizedBox(
        height: SizeConfig.blockSizeVertical! * 2.5,
      ),
      MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: ListView.separated(
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
                      color: bgColor,
                      borderRadius: BorderRadius.circular(cellsRadius / 2)),
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
              Widget resultinging = SizedBox(
                height: separatorHeight,
              );
              DateTime now = DateTime.now();
              Color bgColor = BACKGROUND_COLOR;

              if (isBetween(now, Lesson.second.end, Lesson.third.start)) {
                bgColor = PALE_MAIN_COLOR;
              }
              if (index == 1) {
                resultinging = Container(
                    height: 3,
                    color: bgColor,
                    child: const Column(children: [
                      //Divider(color: Colors.grey, height: 0.5, thickness: 0.5),
                      Spacer(),
                      //Divider(color: Colors.grey, height: 0.5, thickness: 0.5)
                    ]));
              }
              return resultinging;
            },
            itemCount: maxPeriod,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ))
    ]));
  }

  Color cellBackGroundColor(int taskCount, Color color) {
    Color bgColor = color;

    // if (taskCount <= 8) {
    //   bgColor = increaseRed(color, amount: 30 * taskCount);
    // } else {
    //   bgColor = increaseRed(color, amount: 255);
    // }

    return bgColor;
  }

  Color increaseRed(Color color, {int amount = 10}) {
    int red = color.red;
    int green = color.green;
    int blue = color.blue;

    red = (red + amount).clamp(0, 255);

    return Color.fromRGBO(red, green, blue, 1);
  }

  Widget timetableCells(int weekDay, int maxPeriod) {
    final tableData = ref.read(timeTableProvider);
    return SizedBox(
        width: SizeConfig.blockSizeHorizontal! * cellWidth,
        child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: maxPeriod,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemBuilder: ((context, index) {
                Color bgColor = FORGROUND_COLOR;
                Widget cellContents = GestureDetector(onTap: () async {
                  await showModalBottomSheet(
                      context: context,
                      isDismissible: true,
                      isScrollControlled: true,
                      backgroundColor: FORGROUND_COLOR,
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
                    returnExistingPeriod(
                            tableData.currentSemesterClasses[weekDay]!)
                        .contains(index + 1) &&
                    tableData.currentSemesterClasses[weekDay]
                            ?.elementAt(returnIndexFromPeriod(
                                tableData.currentSemesterClasses[weekDay]!,
                                index + 1))
                            .year ==
                        thisYear) {
                  if (tableData.currentSemesterClasses[weekDay]
                              ?.elementAt(returnIndexFromPeriod(
                                  tableData.currentSemesterClasses[weekDay]!,
                                  index + 1))
                              .semester ==
                          currentQuarter ||
                      tableData.currentSemesterClasses[weekDay]
                              ?.elementAt(returnIndexFromPeriod(
                                  tableData.currentSemesterClasses[weekDay]!,
                                  index + 1))
                              .semester ==
                          currentSemester ||
                      tableData.currentSemesterClasses[weekDay]
                              ?.elementAt(returnIndexFromPeriod(
                                  tableData.currentSemesterClasses[weekDay]!,
                                  index + 1))
                              .semester ==
                          Term.fullYear) {
                    cellContents = FutureBuilder(
                        future: TaskDatabaseHelper().getTaskListByCourseName(
                            tableData.currentSemesterClasses[weekDay]
                                    ?.elementAt(returnIndexFromPeriod(
                                        tableData
                                            .currentSemesterClasses[weekDay]!,
                                        index + 1))
                                    .courseName ??
                                ""),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return timeTableCellsChild(weekDay, index + 1, []);
                          } else if (snapshot.hasData) {
                            return timeTableCellsChild(
                                weekDay, index + 1, snapshot.data!);
                          } else {
                            return timeTableCellsChild(weekDay, index + 1, []);
                          }
                        });
                  }
                }

                Color lineColor = BACKGROUND_COLOR;
                double lineWidth = 1;
                DateTime now = DateTime.now();
                double minRadius = 3.5;

                if (isBetween(now, Lesson.atPeriod(index + 1)!.start,
                        Lesson.atPeriod(index + 1)!.end) &&
                    now.weekday == weekDay &&
                    weekDay <= 6) {
                  lineWidth = 4;
                  lineColor = PALE_MAIN_COLOR;
                }
                int maxWeekday = isShowSaturday ? 6 : 5;

                return Container(
                    width: SizeConfig.blockSizeHorizontal! * cellWidth,
                    height: SizeConfig.blockSizeVertical! * cellHeight,
                    decoration: BoxDecoration(
                        color: (weekDay).isEven
                            ? lighten(bgColor, 0.015)
                            : darken(bgColor, 0.015),
                        border: Border.all(
                          color: lineColor,
                          width: lineWidth,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: weekDay == 1 && (index == 2 || index == 0)
                              ? Radius.circular(cellsRadius * 2)
                              : Radius.circular(minRadius),
                          bottomLeft: weekDay == 1 &&
                                  (index == 1 || index == maxPeriod - 1)
                              ? Radius.circular(cellsRadius * 2)
                              : Radius.circular(minRadius),
                          topRight: weekDay == maxWeekday &&
                                  (index == 2 || index == 0)
                              ? Radius.circular(cellsRadius * 2)
                              : Radius.circular(minRadius),
                          bottomRight: weekDay == maxWeekday &&
                                  (index == 1 || index == maxPeriod - 1)
                              ? Radius.circular(cellsRadius * 2)
                              : Radius.circular(minRadius),
                        )),
                    child: cellContents);
              }),
              separatorBuilder: (context, index) {
                Widget resultinging = SizedBox(height: separatorHeight);
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
                      height: 3,
                      color: bgColor,
                      child: const Column(children: [
                        const Spacer(),
                        // Text(
                        //   childText,
                        //   style: TextStyle(
                        //       color: fontColor,
                        //       fontSize: 12,
                        //       fontWeight: FontWeight.bold),
                        // ),
                        const Spacer(),
                      ]));
                }
                return resultinging;
              },
            )));
  }

  Widget generateOndemandRow() {
    final tableData = ref.read(timeTableProvider);
    int listLength = 0;
    if (tableData.sortedDataByWeekDay.containsKey(7)) {
      listLength = tableData.sortedDataByWeekDay[7]!.length;
    }

    return Row(children: [
      SizedBox(width: SizeConfig.blockSizeHorizontal! * cellWidth * 0.5),
      Expanded(
        child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: listLength + 1,
            itemBuilder: (context, index) {
              Widget child = const SizedBox();
              if (index == listLength) {
                child = ondemandAddCell();
                return child;
              } else {
                bool isThisYear =
                    tableData.sortedDataByWeekDay[7]?.elementAt(index).year ==
                        thisYear;

                if ((tableData.sortedDataByWeekDay[7]
                                ?.elementAt(index)
                                .semester
                                ?.value ==
                            currentQuarter.value &&
                        isThisYear) ||
                    (tableData.sortedDataByWeekDay[7]
                                ?.elementAt(index)
                                .semester
                                ?.value ==
                            "full_year" &&
                        isThisYear) ||
                    (tableData.sortedDataByWeekDay[7]
                                ?.elementAt(index)
                                .semester
                                ?.value ==
                            currentSemester.value &&
                        isThisYear)) {
                  child = Container(
                      height: SizeConfig.blockSizeVertical! * cellHeight,
                      width: SizeConfig.blockSizeHorizontal! * cellWidth,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: BACKGROUND_COLOR,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(cellsRadius)),
                      child: FutureBuilder(
                          future: TaskDatabaseHelper().getTaskListByCourseName(
                              tableData.sortedDataByWeekDay[7]
                                      ?.elementAt(index)
                                      .courseName ??
                                  ""),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return ondemandCellsChild(index, []);
                            } else if (snapshot.hasData) {
                              return ondemandCellsChild(index, snapshot.data!);
                            } else {
                              return ondemandCellsChild(index, []);
                            }
                          }));
                }
                return child;
              }
            }),
      )
    ]);
  }

  Widget generateOndemandColumn() {
    final tableData = ref.read(timeTableProvider);
    int listLength = 0;
    if (tableData.sortedDataByWeekDay.containsKey(7)) {
      listLength = tableData.sortedDataByWeekDay[7]!.length;
    }

    return SizedBox(
        width: SizeConfig.blockSizeHorizontal! * cellWidth,
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: listLength + 1,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            Widget child = const SizedBox();
            if (index == listLength) {
              child = ondemandAddCell();
              return child;
            } else {
              bool isThisYear =
                  tableData.sortedDataByWeekDay[7]?.elementAt(index).year ==
                      thisYear;

              if ((tableData.sortedDataByWeekDay[7]
                              ?.elementAt(index)
                              .semester
                              ?.value ==
                          currentQuarter.value &&
                      isThisYear) ||
                  (tableData.sortedDataByWeekDay[7]
                              ?.elementAt(index)
                              .semester
                              ?.value ==
                          "full_year" &&
                      isThisYear) ||
                  (tableData.sortedDataByWeekDay[7]
                              ?.elementAt(index)
                              .semester
                              ?.value ==
                          currentSemester.value &&
                      isThisYear)) {
                child = Container(
                    height: SizeConfig.blockSizeVertical! * cellHeight,
                    width: SizeConfig.blockSizeHorizontal! * cellWidth,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: BACKGROUND_COLOR,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(cellsRadius)),
                    child: FutureBuilder(
                        future: TaskDatabaseHelper().getTaskListByCourseName(
                            tableData.sortedDataByWeekDay[7]
                                    ?.elementAt(index)
                                    .courseName ??
                                ""),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return ondemandCellsChild(index, []);
                          } else if (snapshot.hasData) {
                            return ondemandCellsChild(index, snapshot.data!);
                          } else {
                            return ondemandCellsChild(index, []);
                          }
                        }));
              }
              return child;
            }
          },
          separatorBuilder: (context, index) {
            Widget resultinging = const SizedBox();
            // if (index == 1) {
            //   resultinging = Container(
            //       color:Colors.amberAccent,
            //       height: 3,
            //   );
            // }
            return resultinging;
          },
        ));
  }

  List<int> returnExistingPeriod(List<MyCourse> target) {
    List<int> result = [];
    for (int i = 0; i < target.length; i++) {
      result.add(target.elementAt(i).period!.period);
    }
    return result;
  }

  int returnIndexFromPeriod(List<MyCourse> target, int period) {
    int result = 0;
    for (int i = 0; i < target.length; i++) {
      if (target.elementAt(i).period!.period == period) {
        result = i;
      }
    }
    return result;
  }

  Widget timeTableCellsChild(
      int weekDay, int period, List<Map<String, dynamic>> taskList) {
    double fontSize = SizeConfig.blockSizeVertical! * 1.1;
    final timeTableData = ref.read(timeTableProvider);
    Color bgColor = hexToColor(timeTableData.currentSemesterClasses[weekDay]!
        .elementAt(returnIndexFromPeriod(
            timeTableData.currentSemesterClasses[weekDay]!, period))
        .color);
    MyCourse targetData = timeTableData.currentSemesterClasses[weekDay]!
        .elementAt(returnIndexFromPeriod(
            timeTableData.currentSemesterClasses[weekDay]!, period));
    String className = timeTableData.currentSemesterClasses[weekDay]!
        .elementAt(returnIndexFromPeriod(
            timeTableData.currentSemesterClasses[weekDay]!, period))
        .courseName;
    String? classRoom = timeTableData.currentSemesterClasses[weekDay]
        ?.elementAt(returnIndexFromPeriod(
            timeTableData.currentSemesterClasses[weekDay]!, period))
        .classRoom;
    int taskLength = taskList.length;
    Widget classRoomView = const SizedBox();

    if (classRoom != null &&
        classRoom != "" &&
        classRoom != "-" &&
        classRoom != " ") {
      classRoomView = Container(
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.75),
              borderRadius: const BorderRadius.all(Radius.circular(4))),
          child: Row(children: [
            Expanded(
                child: Center(
                    child: Text(
              classRoom,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: BLACK),
              overflow: TextOverflow.visible,
              maxLines: 2,
            ))),
          ]));
    }
    return Container(
        width: SizeConfig.blockSizeHorizontal! * cellWidth,
        decoration: BoxDecoration(
            color: cellBackGroundColor(taskLength, bgColor).withOpacity(0.6),
            borderRadius: BorderRadius.circular(cellsRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 2,
                offset: const Offset(0, 0),
              ),
            ],
            border: Border.all(width: 0.6, color: Colors.grey)),
        padding: const EdgeInsets.symmetric(horizontal: 3),
        margin: const EdgeInsets.all(1),
        child: InkWell(
            onTap: () async {
              isSelectedlistGenerated = false;
              await CoursePreview(
                target: targetData,
                setTimetableState: setState,
                taskList: taskList,
                isOndemand: false,
              ).showPage(context);
            },
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                doNotContainScreenShot(Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: absentBadgeBuilder(targetData))),
                doNotContainScreenShot(lengthBadge(taskLength, fontSize, true)),
              ]),
              Expanded(
                  child: Center(
                      child: Text(
                className,
                style:
                    TextStyle(fontSize: fontSize, overflow: TextOverflow.clip),
                maxLines: null,
              ))),
              classRoomView,
              const SizedBox(height: 3),
            ])));
  }

  Widget absentBadgeBuilder(MyCourse targetData) {
    int myCourseID = targetData.id!;
    int remainAbsent = targetData.remainAbsent ?? 0;
    return FutureBuilder(
        future: MyCourse.getAttendanceRecordFromDB(myCourseID),
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
            borderRadius: BorderRadius.all(Radius.circular(5))),
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
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: Text(
          " 欠席 $absentNum", // + "/" + remainAbsent.toString(),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: SizeConfig.blockSizeVertical! * cellHeight / 12,
              color: Colors.white),
        ),
      );
    }
  }

  Widget ondemandCellsChild(int index, List<Map<String, dynamic>> taskList) {
    final tableData = ref.read(timeTableProvider);
    MyCourse target = tableData.sortedDataByWeekDay[7]!.elementAt(index);
    double fontSize = 11;
    String className = target.courseName;
    int taskLength = taskList.length;

    Color colorning =
        hexToColor(tableData.sortedDataByWeekDay[7]!.elementAt(index).color);
    Color bgColor = cellBackGroundColor(taskLength, colorning).withOpacity(0.7);

    return GestureDetector(
      onTap: () async {
        await CoursePreview(
          target: target,
          setTimetableState: setState,
          taskList: taskList,
          isOndemand: true,
        ).showPage(context);
      },
      child: Container(
        decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(cellsRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 0),
              ),
            ],
            border: Border.all(width: 0.6, color: Colors.grey)),
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          doNotContainScreenShot(Align(
              alignment: const Alignment(-1, -1),
              child: lengthBadge(taskLength, fontSize, true))),
          Expanded(
              child: Center(
            child: Text(className,
                style: TextStyle(
                    fontSize: fontSize, overflow: TextOverflow.ellipsis),
                maxLines: 4),
          ))
        ]),
      ),
    );
  }

  Widget ondemandAddCell() {
    Color bgColor = FORGROUND_COLOR;
    return doNotContainScreenShot(GestureDetector(
      onTap: () async {
        await showModalBottomSheet(
            context: context,
            isDismissible: true,
            isScrollControlled: true,
            backgroundColor: FORGROUND_COLOR,
            builder: (BuildContext context) {
              return CourseAddPage(
                setTimetableState: setState,
                year: thisYear,
                semester: currentSemester,
                weekDay: DayOfWeek.anotherday,
                period: Lesson.ondemand,
              );
            });
      },
      child: Container(
          height: SizeConfig.blockSizeVertical! * cellHeight,
          width: SizeConfig.blockSizeHorizontal! * cellWidth,
          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          decoration: BoxDecoration(
              color: bgColor, borderRadius: BorderRadius.circular(cellsRadius)),
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: const Center(
              child: Icon(Icons.add_rounded, size: 30, color: Colors.grey))),
    ));
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

  Widget timetableCreditsView() {
    final timetable = ref.read(timeTableProvider);
    List<MyCourse> classesList =
        timetable.targetSemesterClasses(currentSemester, thisYear);
    int creditsTotalSum = timetable.creditsTotalSum(classesList);
    Map<String?, List<MyCourse>> sortedCourseByClassification =
        timetable.sortDataByClassification(classesList);
    Map<Term?, List<MyCourse>> sortedCourseByQuarter =
        timetable.sortDataByQuarter(classesList);

    EdgeInsets padding =
        const EdgeInsets.symmetric(horizontal: 20, vertical: 0);
    EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 15, vertical: 1);
    TextStyle smallGrayChar = const TextStyle(color: Colors.grey, fontSize: 15);
    TextStyle smallBlackChar =
        const TextStyle(color: Colors.black, fontSize: 15);
    TextStyle largeChar =
        const TextStyle(fontWeight: FontWeight.bold, fontSize: 35);

    return Column(children: [
      Container(
        decoration: roundedBoxdecoration(radiusType: 1),
        padding: padding,
        margin: margin,
        child: Row(children: [
          Text("この学期の単位数：", style: smallGrayChar),
          const Spacer(),
          Text(creditsTotalSum.toString(), style: largeChar),
          const Spacer(),
        ]),
      ),
      Container(
          decoration: roundedBoxdecoration(radiusType: 2),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          margin: margin,
          child: classesList.isNotEmpty
              ? MediaQuery.removePadding(
                  context: context,
                  removeBottom: true,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      Term term = sortedCourseByQuarter.keys.elementAt(index) ??
                          Term.others;
                      String termString = term.text;
                      int numOfCredits = 0;
                      for (var course
                          in sortedCourseByQuarter.values.elementAt(index)) {
                        numOfCredits += course.credit ?? 0;
                      }
                      return Text("$termString : ${numOfCredits.toString()} 単位",
                          style: smallGrayChar);
                    },
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sortedCourseByQuarter.length,
                  ))
              : SizedBox(
                  height: 40,
                  child: Center(
                      child: Text("この学期の授業はまだありません。", style: smallGrayChar)))),
      MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: ListView.builder(
            itemBuilder: (context, index) {
              int numOfCredits = timetable.creditsTotalSum(
                  sortedCourseByClassification.values.elementAt(index));
              String classificationName =
                  sortedCourseByClassification.keys.elementAt(index) ?? "分類なし";
              if (!isSelectedlistGenerated) {
                selectedCreditsSum = 0;
                isSelectedList = List<bool>.filled(
                    sortedCourseByClassification.length + 36, false);
              }
              isSelectedlistGenerated = true;
              bool isSelected = isSelectedList.elementAt(index);

              return Container(
                decoration: roundedBoxdecoration(radiusType: 2),
                padding: padding,
                margin: margin,
                child: Row(children: [
                  CupertinoCheckbox(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          isSelectedList[index] = value!;
                          if (value) {
                            selectedCreditsSum += numOfCredits;
                          } else {
                            selectedCreditsSum -= numOfCredits;
                          }
                        });
                      }),
                  Expanded(
                      child: Text(classificationName,
                          style: smallGrayChar, overflow: TextOverflow.clip)),
                  SizedBox(
                      width: 25,
                      child:
                          Text(numOfCredits.toString(), style: smallBlackChar)),
                  GestureDetector(
                    onTap: () async {
                      await showClassificationContentDialog(classificationName,
                          sortedCourseByClassification.values.elementAt(index));
                    },
                    child: const Icon(Icons.more_horiz, color: Colors.grey),
                  )
                ]),
              );
            },
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedCourseByClassification.length,
          )),
      Container(
          decoration: roundedBoxdecoration(radiusType: 3),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          margin: margin,
          child: const RequiredCreditsStats()),
    ]);
  }

  Color colorSettingsColor = Colors.red;

  Future<void> showClassificationContentDialog(
      String? classificationName, List<MyCourse> courseList) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: FORGROUND_COLOR,
            title: Text("'${classificationName ?? "分類なし"}' の内訳",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            content: SingleChildScrollView(
              child: SizedBox(
                  width: double.maxFinite,
                  child: Column(children: [
                    ListView.builder(
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            onTap: () {},
                            child: Container(
                                decoration: roundedBoxdecoration(
                                    radiusType: 2,
                                    backgroundColor: BACKGROUND_COLOR),
                                margin: const EdgeInsets.symmetric(
                                    vertical: 1, horizontal: 5),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                child: Text(
                                    courseList.elementAt(index).courseName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold))));
                      },
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: courseList.length,
                    ),

                    // const SizedBox(height: 10),

                    // Row(children: [
                    //   const Text("この科目群を一括で着色：",
                    //     style:TextStyle(color:Colors.grey,fontSize:12)),
                    //   colorSettingButton(
                    //     context,
                    //     setState,
                    //     colorSettingsColor,
                    //     (value) async{
                    //       for(var course in courseList){
                    //         int id = course.id!;
                    //         await MyCourse.updateColor(id,value);
                    //       }
                    //       setState((){});
                    //     }
                    //   )
                    // ])
                  ])),
            ),
            actions: [okButton(context, 700.0)],
          );
        });
  }
}
