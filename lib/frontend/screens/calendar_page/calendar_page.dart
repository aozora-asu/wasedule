import 'package:flutter_calandar_app/converter.dart';
import 'package:flutter_calandar_app/frontend/assist_files/data_loader.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/common/logo_and_title.dart';
import 'package:flutter_calandar_app/frontend/screens/common/tutorials.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_modal_sheet.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/course_preview.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/timetable_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/todo_daily_view_page/todo_daily_view_page.dart';
import 'package:screenshot/screenshot.dart';
import 'package:nholiday_jp/nholiday_jp.dart';

import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/arbeit_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/handler/schedule_template_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/handler/user_info_db_handler.dart';

import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/tag_and_template_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/arbeit_stats_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/how_to_use_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/setting_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/sns_link_page.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/daily_view_page.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_data_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../assist_files/size_config.dart';
import 'add_event_button.dart';

import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:async';

import '../../../backend/notify/notify_setting.dart';

var random = Random(DateTime.now().millisecondsSinceEpoch);
var randomNumber = random.nextInt(10); // 0から10までの整数を生成

class Calendar extends ConsumerStatefulWidget {
  const Calendar({
    super.key,
  });
  // final NotificationAppLaunchDetails? notificationAppLaunchDetails;
  // bool get didNotificationLaunchApp =>
  //     notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends ConsumerState<Calendar> {
  final ScreenshotController _screenShotController = ScreenshotController();
  late bool isScreenShotBeingTaken;
  late String targetMonth = "";
  String thisMonth = "${DateTime.now().year}/${DateTime.now().month.toString().padLeft(2, '0')}";
  String today = "${DateTime.now().year}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().day.toString().padLeft(2, '0')}";
  late int thisYear;
  late int semesterNum;
  late String targetSemester;

  @override
  void initState() {
    super.initState();
    initTargetSem();
    LocalNotificationSetting().requestIOSPermission();
    LocalNotificationSetting().requestAndroidPermission();
    LocalNotificationSetting().initializePlatformSpecifics();
    displayDB();
    targetMonth = thisMonth;
    generateCalendarData();
    _initializeData();
    isScreenShotBeingTaken = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _getTemplateDataSource() async {
    List<Map<String, dynamic>> templateList =
        await ScheduleTemplateDatabaseHelper().getScheduleTemplateFromDB();

    return templateList;
  }

  Future<List<Map<String, dynamic>>> _getArbeitDataSource() async {
    List<Map<String, dynamic>> arbeitList =
        await ArbeitDatabaseHelper().getArbeitFromDB();
    return arbeitList;
  }

  TaskDatabaseHelper databaseHelper = TaskDatabaseHelper();
  String? urlString;
  Future<List<Map<String, dynamic>>>? events;

  bool setIsAllDay(Map<String, dynamic> schedule) {
    //startTimeとendTimeのどちらも空だった場合にtrueを返す
    if (schedule['startTime'] == null && schedule['endTime'] == null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _initializeData() async {
    urlString = await UserDatabaseHelper().getUrl();
    if (urlString != null) {
      await displayDB();
    } else {
      noneTaskText();
    }
  }

  Widget noneTaskText() {
    return const Text("現在課題はありません。");
  }

  List<Map<String, dynamic>> taskData = [];

  Future<void> displayDB() async {
    final addData = await databaseHelper.getTaskFromDB();
    if (mounted) {
      setState(() {
        events = Future.value(addData);
      });
      taskData = [];
      taskData.addAll(addData);
    }
  }

  void _showTutorial(BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    if (pref.getBool('hasCompletedIntro') != true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const IntroPage(),
          fullscreenDialog: true,
        ),
      );
      //pref.setBool('hasCompletedIntro', true);
    } else if (pref.getBool('hasCompletedCalendarIntro') != true) {
      showScheduleGuide(context);
      pref.setBool('hasCompletedCalendarIntro', true);
    }
  }

  void initTargetSem() {
    DateTime now = DateTime.now();
    thisYear = datetime2schoolYear(now);
    List semesterList = datetime2termList(now);

    if (now.month <= 3) {
      thisYear -= 1;
    }
    semesterNum = 5;
    if (now.month == 1) {
      semesterNum = 4;
    } else if (now.month == 4 || now.month == 5) {
      semesterNum = 1;
    } else if (now.month == 6 || now.month == 7) {
      semesterNum = 2;
    } else if (now.month == 10 || now.month == 11) {
      semesterNum = 3;
    } else if (now.month == 12) {
      semesterNum = 4;
    } else {
      semesterNum == 5;
    }

    if(semesterList.isNotEmpty){
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

  Future<List<Map<String, dynamic>>> loadDataBases() async {
    await ConfigDataLoader().initConfig(ref);
    await ref
        .read(calendarDataProvider)
        .getTagData(TagDataLoader().getTagDataSource());
    await ref
        .read(calendarDataProvider)
        .getConfigData(ConfigDataLoader().getConfigDataSource());
    await ref
        .read(calendarDataProvider)
        .getTemplateData(_getTemplateDataSource());
    await ref.read(calendarDataProvider).getArbeitData(_getArbeitDataSource());
    await ref
        .read(timeTableProvider)
        .getData(TimeTableDataLoader().getTimeTableDataSource());
    List<Map<String, dynamic>> result =
        await CalendarDataLoader().getDataSource();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTutorial(context);
    });

    ref.watch(calendarDataProvider);
    SizeConfig().init(context);
    ScrollController controller = ScrollController();
    return Scaffold(
        body: Container(
          decoration:const BoxDecoration(
            //   image: DecorationImage(
            // image: calendarBackGroundImage(),
            // fit: BoxFit.cover)
            color:BACKGROUND_COLOR
          ),
          child: Scrollbar(
            controller: controller,
            interactive: true,
            radius: const Radius.circular(20),
            thumbVisibility: true,
            child:ListView(
              primary: false,
              controller:controller, 
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: SizeConfig.blockSizeHorizontal! *0, //2.5,
                    right: SizeConfig.blockSizeHorizontal! *0,
                  ),
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: loadDataBases(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // データが取得されるまでの間
                        return calendarBody();
                      } else if (snapshot.hasError) {
                        // エラーがある場合
                        return const SizedBox();
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        //カレンダーが空の場合
                        if (ref.read(taskDataProvider).isRenewed) {
                          displayDB();
                          ref.read(taskDataProvider).isRenewed = false;
                        }
                        ref.read(calendarDataProvider).sortDataByDay();
                        ref.read(timeTableProvider).sortDataByWeekDay(
                            ref.read(timeTableProvider).timeTableDataList);
                        return calendarBody();
                      } else {
                        //カレンダーがデータを持っている場合
                        if (ref.read(taskDataProvider).isRenewed) {
                          displayDB();
                          ref.read(taskDataProvider).isRenewed = false;
                        }
                        ref.read(calendarDataProvider).getData(snapshot.data!);
                        ref.read(taskDataProvider).getData(taskData);
                        ref.read(calendarDataProvider).sortDataByDay();
                        ref.read(timeTableProvider).sortDataByWeekDay(
                            ref.read(timeTableProvider).timeTableDataList);
                        ref
                            .read(timeTableProvider)
                            .initUniversityScheduleByDay(thisYear, semesterNum);
                        return calendarBody();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Container(
            margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical! * 12),
            child: Row(children: [
              const Spacer(),
              const AddEventButton(),
              const SizedBox(width: 10),
              calendarShareButton(context),
            ])));
  }

  AssetImage calendarBackGroundImage() {
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

  Widget calendarBody() {
    generateHoliday();
    return Column(children: [
      switchWidget(tipsAndNewsPanel(randomNumber, ""),
          ConfigDataLoader().searchConfigData("tips", ref)),
      const SizedBox(height: 10),
      switchWidget(todaysScheduleListView(),
          ConfigDataLoader().searchConfigData("todaysSchedule", ref)),
      switchWidget(
          taskDataListList(
              ConfigDataLoader().searchConfigInfo("taskList", ref)),
          ConfigDataLoader().searchConfigData("taskList", ref)),
      Screenshot(
          controller: _screenShotController,
          child: SizedBox(
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
                        targetMonth,
                        style: const TextStyle(
                          fontSize: 25,
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
                      doNotContainScreenShot(scheduleEmptyFlag(
                        ref,
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal! * 40,
                          height: SizeConfig.blockSizeVertical! * 4,
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const TagAndTemplatePage()),
                              );
                            },
                            icon: const Icon(Icons.tag,
                                size: 15, color: WHITE),
                            label: const Text('タグとテンプレート',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: WHITE,
                                    fontWeight: FontWeight.bold)),
                            style: const ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(BLUEGREY),
                            ),
                          ),
                        ),
                      )),
                      showOnlyScreenShot(LogoAndTitle(size: 7)),
                     SizedBox(
                          width: SizeConfig.blockSizeHorizontal! * 3)
                    ]),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal! * 100,
                      height: SizeConfig.blockSizeVertical! * 3,
                      child: generateWeekThumbnail(),
                    ),
                    SizedBox(
                        width: SizeConfig.blockSizeHorizontal! * 100,
                        child: Row(children: [
                          generateCalendarCells("sunday"),
                          generateCalendarCells("monday"),
                          generateCalendarCells("tuesday"),
                          generateCalendarCells("wednesday"),
                          generateCalendarCells("thursday"),
                          generateCalendarCells("friday"),
                          generateCalendarCells("saturday")
                        ])),
                    Row(children: [
                      const Spacer(),
                      showOnlyScreenShot(screenShotDateTime()),
                      const SizedBox(width: 7)
                    ]),
                  ])))),
      menu()
    ]);
  }

  Widget menu() {
    return Column(children: [
      SizedBox(
        height: SizeConfig.blockSizeVertical! * 3,
      ),
      Column(children: [
        tagEmptyFlag(
            ref,
            GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ArbeitStatsPage(targetMonth: targetMonth,isAppbar: true,)));
                },
                child: menuList(Icons.currency_yen, "",false,
                 [
                  menuListChild(Icons.currency_yen, "アルバイト", () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                ArbeitStatsPage(targetMonth: targetMonth,isAppbar: true)));
                  }),
                  loadArbeitStatsPreview(targetMonth)
                ],showIcon: false
                ))),

        const SizedBox(height: 15),
          menuListChild(Icons.settings, "設定", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          }),
          menuListChild(Icons.info, "サポート", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SnsLinkPage()),
            );
          }),
        const SizedBox(height: 15),
        const SizedBox(height: 20),
      ])
    ]);
  }

  Widget calendarShareButton(BuildContext context) {
    return FloatingActionButton(
        heroTag: "calendar_2",
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

  void increasePgNumber() {
    String increasedMonth = "";

    if (targetMonth.substring(5, 7) == "12") {
      int year = int.parse(targetMonth.substring(0, 4));
      year += 1;
      setState(() {
        renewSemesterNum(year, 12);
        increasedMonth = "$year/01";
      });
    } else {
      int year = int.parse(targetMonth.substring(0, 4));
      int month = int.parse(targetMonth.substring(5, 7));
      month += 1;
      setState(() {
        renewSemesterNum(year, month);
        increasedMonth =
            targetMonth.substring(0, 5) + month.toString().padLeft(2, '0');
      });
    }
    targetMonth = increasedMonth;
    generateCalendarData();
  }

  void decreasePgNumber() {
    String decreasedMonth = "";

    if (targetMonth.substring(5, 7) == "01") {
      int year = int.parse(targetMonth.substring(0, 4));
      year -= 1;
      setState(() {
        renewSemesterNum(year, 12);
        decreasedMonth = "$year/12";
      });
    } else {
      int year = int.parse(targetMonth.substring(0, 4));
      int month = int.parse(targetMonth.substring(5, 7));
      month -= 1;
      setState(() {
        renewSemesterNum(year, month);
        decreasedMonth =
            targetMonth.substring(0, 5) + month.toString().padLeft(2, '0');
      });
    }
    targetMonth = decreasedMonth;
    generateCalendarData();
  }

  void renewSemesterNum(int year, int month) {
    thisYear = year;
    if (month <= 3) {
      thisYear -= 1;
    }
    semesterNum = 5;
    if (month == 1) {
      semesterNum = 4;
    } else if (month == 4 || month == 5) {
      semesterNum = 1;
    } else if (month == 6 || month == 7) {
      semesterNum = 2;
    } else if (month == 10 || month == 11) {
      semesterNum = 3;
    } else if (month == 12) {
      semesterNum = 4;
    } else {
      semesterNum == 5;
    }
    targetSemester = "$thisYear-$semesterNum";
  }

  Map<String, List<DateTime>> generateCalendarData() {
    DateTime firstDay = DateTime(int.parse(targetMonth.substring(0, 4)),
        int.parse(targetMonth.substring(5, 7)));
    List<DateTime> firstWeek = [];

    List<DateTime> sunDay = [];
    List<DateTime> monDay = [];
    List<DateTime> tuesDay = [];
    List<DateTime> wednesDay = [];
    List<DateTime> thursDay = [];
    List<DateTime> friDay = [];
    List<DateTime> saturDay = [];

    switch (firstDay.weekday) {
      case 1:
        firstWeek = [
          firstDay.subtract(const Duration(days: 1)),
          firstDay,
          firstDay.add(const Duration(days: 1)),
          firstDay.add(const Duration(days: 2)),
          firstDay.add(const Duration(days: 3)),
          firstDay.add(const Duration(days: 4)),
          firstDay.add(const Duration(days: 5)),
        ];
      case 2:
        firstWeek = [
          firstDay.subtract(const Duration(days: 2)),
          firstDay.subtract(const Duration(days: 1)),
          firstDay,
          firstDay.add(const Duration(days: 1)),
          firstDay.add(const Duration(days: 2)),
          firstDay.add(const Duration(days: 3)),
          firstDay.add(const Duration(days: 4)),
        ];
      case 3:
        firstWeek = [
          firstDay.subtract(const Duration(days: 3)),
          firstDay.subtract(const Duration(days: 2)),
          firstDay.subtract(const Duration(days: 1)),
          firstDay,
          firstDay.add(const Duration(days: 1)),
          firstDay.add(const Duration(days: 2)),
          firstDay.add(const Duration(days: 3)),
        ];
      case 4:
        firstWeek = [
          firstDay.subtract(const Duration(days: 4)),
          firstDay.subtract(const Duration(days: 3)),
          firstDay.subtract(const Duration(days: 2)),
          firstDay.subtract(const Duration(days: 1)),
          firstDay,
          firstDay.add(const Duration(days: 1)),
          firstDay.add(const Duration(days: 2)),
        ];
      case 5:
        firstWeek = [
          firstDay.subtract(const Duration(days: 5)),
          firstDay.subtract(const Duration(days: 4)),
          firstDay.subtract(const Duration(days: 3)),
          firstDay.subtract(const Duration(days: 2)),
          firstDay.subtract(const Duration(days: 1)),
          firstDay,
          firstDay.add(const Duration(days: 1)),
        ];
      case 6:
        firstWeek = [
          firstDay.subtract(const Duration(days: 6)),
          firstDay.subtract(const Duration(days: 5)),
          firstDay.subtract(const Duration(days: 4)),
          firstDay.subtract(const Duration(days: 3)),
          firstDay.subtract(const Duration(days: 2)),
          firstDay.subtract(const Duration(days: 1)),
          firstDay,
        ];
      case 7:
        firstWeek = [
          firstDay,
          firstDay.add(const Duration(days: 1)),
          firstDay.add(const Duration(days: 2)),
          firstDay.add(const Duration(days: 3)),
          firstDay.add(const Duration(days: 4)),
          firstDay.add(const Duration(days: 5)),
          firstDay.add(const Duration(days: 6)),
        ];
      default:
        firstWeek = [
          firstDay,
          firstDay.add(const Duration(days: 1)),
          firstDay.add(const Duration(days: 2)),
          firstDay.add(const Duration(days: 3)),
          firstDay.add(const Duration(days: 4)),
          firstDay.add(const Duration(days: 5)),
          firstDay.add(const Duration(days: 6)),
        ];
    }
    sunDay = generateWeek(firstWeek.elementAt(0));
    monDay = generateWeek(firstWeek.elementAt(1));
    tuesDay = generateWeek(firstWeek.elementAt(2));
    wednesDay = generateWeek(firstWeek.elementAt(3));
    thursDay = generateWeek(firstWeek.elementAt(4));
    friDay = generateWeek(firstWeek.elementAt(5));
    saturDay = generateWeek(firstWeek.elementAt(6));

    Map<String, List<DateTime>> result = {
      "sunday": sunDay,
      "monday": monDay,
      "tuesday": tuesDay,
      "wednesday": wednesDay,
      "thursday": thursDay,
      "friday": friDay,
      "saturday": saturDay
    };

    return result;
  }

  Widget generateWeekThumbnail() {
    List<String> days = ["日", "月", "火", "水", "木", "金", "土"];
    return ListView.builder(
      itemBuilder: (context, index) {
        return SizedBox(
            width: SizeConfig.blockSizeHorizontal! * 14.285,
            height: SizeConfig.blockSizeVertical! * 2,
            child: Center(
                child: Text(
              days.elementAt(index),
              style: const TextStyle(
                color: BLUEGREY,
                fontWeight:FontWeight.bold),
            )));
      },
      itemCount: 7,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  List<DateTime> generateWeek(DateTime firstDayOfDay) {
    List<DateTime> result = [
      firstDayOfDay,
      firstDayOfDay.add(const Duration(days: 7)),
      firstDayOfDay.add(const Duration(days: 14)),
      firstDayOfDay.add(const Duration(days: 21)),
      firstDayOfDay.add(const Duration(days: 28)),
      firstDayOfDay.add(const Duration(days: 35))
    ];
    return result;
  }

  List<bool> isHoliday = [];
  List<int> holidayDay = [];

  void generateHoliday() {
    isHoliday = [];
    holidayDay = [];
    DateTime targetmonthDT = DateTime(int.parse(targetMonth.substring(0, 4)),
        int.parse(targetMonth.substring(5, 7)));
    var holidaysOfMonth =
        NHolidayJp.getByMonth(targetmonthDT.year, targetmonthDT.month);

    for (int i = 0; i < holidaysOfMonth.length; i++) {
      if (targetmonthDT.month >= 10) {
        holidayDay.add(
            int.parse(holidaysOfMonth.elementAt(i).toString().substring(3, 5)));
      } else {
        holidayDay.add(
            int.parse(holidaysOfMonth.elementAt(i).toString().substring(2, 4)));
      }
    }

    for (int i = 0; i < LengthOfMonth(targetMonth) + 1; i++) {
      if (holidayDay.contains(i)) {
        isHoliday.add(true);
      } else {
        isHoliday.add(false);
      }
    }
  }

  Widget holidayName(DateTime target) {
    if (target.month == int.parse(targetMonth.substring(5)) &&
        ConfigDataLoader().searchConfigData("holidayName", ref) == 1) {
      if (isHoliday.elementAt(target.day)) {
        return Column(children: [
          Text(
            NHolidayJp.getName(target.year, target.month, target.day),
            style: const TextStyle(color: Colors.red, fontSize: 9),
          ),
          const SizedBox(height: 5)
        ]);
      } else {
        return const SizedBox();
      }
    } else {
      return const SizedBox();
    }
  }

  Widget generateCalendarCells(String dayOfWeek) {
    return SizedBox(
        width: SizeConfig.blockSizeHorizontal! * 14.285,
        child: ListView.builder(
          itemBuilder: (context, index) {
            DateTime target =
                generateCalendarData()[dayOfWeek]!.elementAt(index);
            return InkWell(
              child: Container(
                  width: SizeConfig.blockSizeHorizontal! * 14.285,
                  height: SizeConfig.blockSizeVertical! * 14,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.5),
                    color: cellColour(target),
                    border: Border.all(
                      color: BACKGROUND_COLOR,
                      width: 1,
                    ),
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                target.day.toString(),
                                style: TextStyle(
                                  color: dateColour(target),
                                  fontWeight:FontWeight.bold)
                                )),
                          const Spacer(),
                          doNotContainScreenShot(taskListLength(target, 9.0)),
                          const SizedBox(width: 3)
                        ]),
                        Expanded(child: calendarCellsChild(target)),
                        holidayName(target),
                      ])),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return DailyViewPage(target: target);
                    });
              },
            );
          },
          itemCount: generateCalendarData()[dayOfWeek]!.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
        ));
  }

  Color cellColour(DateTime target) {
    DateTime targetmonthDT = DateTime(int.parse(targetMonth.substring(0, 4)),
        int.parse(targetMonth.substring(5, 7)));

    if (target.year == DateTime.now().year &&
        target.month == DateTime.now().month &&
        target.day == DateTime.now().day) {
      return const Color.fromARGB(255, 255, 160, 160);
    } else if (target.month != targetmonthDT.month) {
      return const Color.fromARGB(255, 225, 225, 225);
    } else if (isHoliday.elementAt(target.day) &&
        ConfigDataLoader().searchConfigData("holidayPaint", ref) == 1) {
      return const Color.fromARGB(255, 255, 200, 200);
    } else if (target.weekday == 6 &&
        ConfigDataLoader().searchConfigData("holidayPaint", ref) == 1) {
      return const Color.fromARGB(255, 225, 225, 255);
    } else if (target.weekday == 7 &&
        ConfigDataLoader().searchConfigData("holidayPaint", ref) == 1) {
      return const Color.fromARGB(255, 255, 215, 215);
    } else {
      return WHITE;
    }
  }


  Color dateColour(DateTime target) {
    DateTime targetmonthDT = DateTime(int.parse(targetMonth.substring(0, 4)),
        int.parse(targetMonth.substring(5, 7)));

    if (target.year == DateTime.now().year &&
        target.month == DateTime.now().month &&
        target.day == DateTime.now().day) {
      return BLUEGREY;
    } else if (target.month != targetmonthDT.month) {
      return const Color.fromARGB(255, 170, 170, 170);
    } else if (isHoliday.elementAt(target.day) &&
        ConfigDataLoader().searchConfigData("holidayPaint", ref) == 1) {
      return BLUEGREY;
    } else if (target.weekday == 6 &&
        ConfigDataLoader().searchConfigData("holidayPaint", ref) == 1) {
      return BLUEGREY;
    } else if (target.weekday == 7 &&
        ConfigDataLoader().searchConfigData("holidayPaint", ref) == 1) {
      return BLUEGREY;
    } else {
      return BLUEGREY;
    }
  }

  Color cellChildColour(DateTime target) {
    DateTime targetmonthDT = DateTime(int.parse(targetMonth.substring(0, 4)),
        int.parse(targetMonth.substring(5, 7)));

    if (target.year == DateTime.now().year &&
        target.month == DateTime.now().month &&
        target.day == DateTime.now().day) {
      return lighten(cellColour(target));
    } else if (target.month != targetmonthDT.month) {
      return const Color.fromARGB(255, 225, 225, 225);
    } else if (isHoliday.elementAt(target.day) &&
        ConfigDataLoader().searchConfigData("holidayPaint", ref) == 1) {
      return lighten(cellColour(target),0.03);
    } else if (target.weekday == 6 &&
        ConfigDataLoader().searchConfigData("holidayPaint", ref) == 1) {
      return lighten(cellColour(target),0.03);
    } else if (target.weekday == 7 &&
        ConfigDataLoader().searchConfigData("holidayPaint", ref) == 1) {
      return lighten(cellColour(target),0.03);
    } else {
      return BACKGROUND_COLOR;
    }
  }

  Widget taskListLength(target, fontSize) {
    final taskData = ref.watch(taskDataProvider);
    Map<DateTime, List<Map<String, dynamic>>> sortedData =
        taskData.sortDataByDtEnd(taskData.taskDataList);

    if (sortedData[target] == null) {
      return const SizedBox();
    } else {
      return Container(
          decoration: const BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
          ),
          padding: EdgeInsets.all(fontSize / 3),
          child: Text(
            (sortedData[target]?.length ?? 0).toString(),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: WHITE,
                fontSize: fontSize),
          ));
    }
  }

  Widget calendarCellsChild(DateTime target) {
    final data = ref.read(calendarDataProvider);
    String targetKey = "${target.year}-${target.month.toString().padLeft(2, "0")}-${target.day.toString().padLeft(2, "0")}";
    List targetDayData = data.sortedDataByDay[targetKey] ?? [];
    DateTime targetDay = DateTime.parse(targetKey);
    DateTime now = DateTime.now();
    List<Map<DateTime, Widget>> mixedDataByTime = [];

    Widget dividerModel =
      const Divider(
        height: 0.7,
        indent: 2,
        endIndent: 2,
        thickness: 0.7,
      );

    //まずは予定データの生成
    for (int index = 0; index < targetDayData.length; index++) {
      DateTime key = DateTime(now.year, now.month, now.day - 1, 0, 0, 0);

      if (targetDayData.elementAt(index)["startTime"].trim() != "") {
        DateFormat format = DateFormat.Hm();
        DateTime time =
            format.parse(targetDayData.elementAt(index)["startTime"]);
        key = DateTime(now.year, now.month, now.day, time.hour, time.minute, 0);
      }

      Widget value = const SizedBox();
      value = 
        scheduleListChild(targetDayData, index,target);
      
      mixedDataByTime.add({key: value});
    }

    //予定データが生成されたところに時間割データを混ぜる
    final timeTable = ref.read(timeTableProvider);
    List<Map<String, dynamic>> targetDayList =timeTable.targetDateClasses(target);
    if(targetDayList.isNotEmpty) {

      Map firstClass = targetDayList.first;
      Map lastClass = targetDayList.last;
      String universityClassData =
        "${timeTable.returnBeginningTime(firstClass["period"])}~${timeTable.returnEndTime(lastClass["period"])}";
      
      DateTime key = timeTable.returnBeginningDateTime(firstClass["period"]);
      Widget value = switchWidget(
          classListChild(universityClassData,target),
        ConfigDataLoader().searchConfigData("timetableInDailyView", ref));
      mixedDataByTime.add({key: value});
    }

    //グチャグチャなデータをソートする
    List<Map<DateTime, dynamic>> sortMapsByFirstKey(
        List<Map<DateTime, dynamic>> list) {
      list.sort((a, b) => a.keys.first.compareTo(b.keys.first));
      return list;
    }

    List<Map<DateTime, dynamic>> sortedList =
        sortMapsByFirstKey(mixedDataByTime);

      return SizedBox(
          child: ListView.builder(
              itemBuilder: (context, index) {
                return sortedList.elementAt(index).values.first;
              },
              itemCount: mixedDataByTime.length,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics()));
  }

  Widget scheduleListChild(targetDayData,index,target){
    Widget dateTimeData = Container();
    if (targetDayData.elementAt(index)["startTime"].trim() != "" &&
          targetDayData.elementAt(index)["endTime"].trim() != "") {
        dateTimeData = Text(
          "${" " +
              targetDayData.elementAt(index)["startTime"]}～" +
              targetDayData.elementAt(index)["endTime"],
          style: const TextStyle(color: Colors.grey, fontSize: 7),
        );
      } else if (targetDayData.elementAt(index)["startTime"].trim() !=
          "") {
        dateTimeData = Text(
          " " + targetDayData.elementAt(index)["startTime"],
          style: const TextStyle(color: Colors.grey, fontSize: 7),
        );
      } else {
        dateTimeData = const Text(
          " 終日",
          style: TextStyle(color: Colors.grey, fontSize: 7),
        );
      }
      return publicContainScreenShot(
          SizedBox(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: dateTimeData),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      tagThumbnail(
                          targetDayData.elementAt(index)["tagID"]),
                      Flexible(
                        child: Text(
                          " " +
                              targetDayData
                                  .elementAt(index)["subject"],
                          style: const TextStyle(
                              color: BLACK, fontSize: 8),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ]),
                Divider(
                  height: 2,
                  indent: 2.75,
                  endIndent: 2.75,
                  thickness: 2,
                  color:cellChildColour(target)
                )
              ])),
          targetDayData.elementAt(index)["isPublic"]);
  }

  Widget classListChild(String universityClassData,target){
    Widget universityClassView = const SizedBox();
    if (universityClassData != "") {
      universityClassView = switchWidget(
          Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              margin: const EdgeInsets.symmetric(horizontal: 1),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(universityClassData,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 7)),
                    const Row(children: [
                      Icon(Icons.school, color: MAIN_COLOR, size: 8),
                      Text(" 授業",
                          style: TextStyle(
                              color: BLACK, fontSize: 8)),
                    ]),
                    Divider(
                      height: 2,
                      indent: 2.75,
                      endIndent: 2.75,
                      thickness: 2,
                      color:cellChildColour(target),

                    )
                  ])),
          ConfigDataLoader()
              .searchConfigData("timetableInCalendarcell", ref));
    }
    return universityClassView;
  }

  Widget tagThumbnail(id) {
    if (id == null) {
      return Container();
    } else {
      if (returnTagColor(id, ref) == null) {
        return Container();
      } else {
        return Row(children: [
          const SizedBox(width: 1),
          Container(width: 4, height: 8, color: returnTagColor(id, ref))
        ]);
      }
    }
  }

  Widget screenShotDateTime() {
    String date = DateFormat("yyyy年MM月dd日 HH時mm分 時点").format(DateTime.now());
    return Text(date, style: const TextStyle(fontSize: 10));
  }

  Widget menuPanel(IconData icon, String text, void Function() ontap) {
    return InkWell(
      onTap: ontap,
      child: Container(
        width: SizeConfig.blockSizeHorizontal! * 45,
        height: SizeConfig.blockSizeHorizontal! * 45,
        decoration: BoxDecoration(
          color: WHITE,
          borderRadius: BorderRadius.circular(20), // 角丸の半径を指定
        ),
        child: Center(
            child: Column(children: [
          const Spacer(),
          Icon(icon, color: MAIN_COLOR, size: 80),
          Text(text, style: const TextStyle(fontSize: 15)),
          const Spacer(),
        ])),
      ),
    );
  }

  Widget expandedMenuPanel(IconData icon, String text, void Function() ontap) {
    return InkWell(
      onTap: ontap,
      child: Container(
        width: SizeConfig.blockSizeHorizontal! * 95,
        height: SizeConfig.blockSizeHorizontal! * 45,
        decoration: BoxDecoration(
          color: WHITE,
          borderRadius: BorderRadius.circular(20), // 角丸の半径を指定
        ),
        child: Center(
            child: Column(children: [
          const Spacer(),
          Icon(icon, color: MAIN_COLOR, size: 80),
          Text(text, style: const TextStyle(fontSize: 15)),
          const Spacer(),
        ])),
      ),
    );
  }

  Widget menuListChild(IconData icon, String text, void Function() ontap) {
    return InkWell(
        onTap: ontap,
        child: Column(children: [
          Container(
              decoration: roundedBoxdecorationWithShadow(radiusType: 2),
              width: SizeConfig.blockSizeHorizontal! * 95,
              height: SizeConfig.blockSizeVertical! * 6,
              child: Center(
                  child: Row(children: [
                const SizedBox(width: 20),
                Icon(icon, color: MAIN_COLOR, size: 40),
                const Spacer(),
                Text(text,
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal! * 5,
                    )),
                const Spacer(),
              ]))),
          Container(height:2,color:BACKGROUND_COLOR)
        ]));
  }

  Widget taskListChild(
      Widget child, void Function() ontap, bool isDivider, bool isIndent) {
    double indent = 0;
    BorderRadius radius = BorderRadius.circular(0);
    if (!isIndent) {
      indent = 10;
    }
    indent = 10;
    
      radius = BorderRadius.circular(20);

    Widget divider = const SizedBox();
    if (isDivider && !isIndent) {
      divider =
          Divider(height: 1, thickness: 1, indent: indent, endIndent: indent);
    }

    return InkWell(
        onTap: ontap,
        child: Column(children: [
          Container(
              width: SizeConfig.blockSizeHorizontal! * 95,
              decoration:BoxDecoration(
                color: WHITE,
                borderRadius: radius
                ),
              child: child),
        ]));
  }

  Widget taskListHeader(String text, int fromNow) {
    Color accentColor = Colors.blueGrey;
    if (fromNow <= 3) {
      accentColor = Colors.red;
    }

    return Column(children: [
      Container(
          width: SizeConfig.blockSizeHorizontal! * 95,
          height: SizeConfig.blockSizeVertical! * 3,
          color: WHITE,
          child: Center(
              child: Row(children: [
            const SizedBox(width: 10),
            Container(
                width: SizeConfig.blockSizeVertical! * 1,
                height: SizeConfig.blockSizeVertical! * 2,
                color: accentColor),
            const SizedBox(width: 5),
            Text(text,
                style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal! * 4,
                    color: BLACK,
                    fontWeight: FontWeight.bold)),
            const Spacer(),
          ]))),
      const Divider(height: 2,thickness:2, indent: 10, endIndent: 10, color:BACKGROUND_COLOR)
    ]);
  }

  Widget menuList(IconData headerIcon, String headerText, bool showCustomButton,
      List<Widget> child,{bool showIcon = true}) {
    Widget customButton = const SizedBox();
    if (showCustomButton) {
      customButton = InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          },
          child: Icon(Icons.settings,
              size: SizeConfig.safeBlockVertical! * 2.5, color: Colors.grey));
    }
    Widget icon = const SizedBox();
      if (showIcon) {
        icon = Icon(headerIcon,
          size: SizeConfig.safeBlockVertical! * 2,
          color: Colors.grey);
      }

    return Container(
        width: SizeConfig.blockSizeHorizontal! * 95,
        decoration: BoxDecoration(
          color: WHITE,
          borderRadius: BorderRadius.circular(20), // 角丸の半径を指定
        ),
        child: Column(children: [
          SizedBox(
              height: SizeConfig.safeBlockVertical! * 3,
              child: Row(children: [
                const SizedBox(width:15),
                icon,
                Text(
                  " $headerText",
                  style: TextStyle(
                      fontSize: SizeConfig.safeBlockVertical! * 1.7,
                      color: Colors.grey),
                ),
                const Spacer(),
                customButton,
                const SizedBox(width: 20),
              ])),
          //const Divider(height: 1),
          ListView.builder(
            itemBuilder: (context, index) {
              return child.elementAt(index);
            },
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: child.length,
          ),
          //SizedBox(height: SizeConfig.safeBlockVertical! * 2),
        ]));
  }

  Widget switchWidget(Widget widget, int isVisible) {
    if (isVisible == 1) {
      return Column(children: [widget]);
    } else {
      return const SizedBox();
    }
  }

  Widget tipsAndNewsPanel(int rundomNum, String newsText) {
    String today = DateFormat('MM月dd日').format(DateTime.now());
    String category = "TIPS";
    String content = "";
    if (newsText != "") {
      category = "お知らせ";
      content = newsText;
    } else {
      switch (rundomNum) {
        case 0:
          content = "アルバイトタグを予定に紐づけて、一目で見込み月収をチェック！\n ＞＞『アルバイト』から";
        case 1:
          content = "今日は何時間勉強した？学習記録ページで管理しよう \n＞＞『学習管理』から";
        case 2:
          content = "アプリのデータをバックアップして、別端末に移行できます！  \n＞＞『データバックアップ』から";
        // "公式サイトにてみんなの授業課題データベースが公開中！楽単苦単をチェック\n＞＞『使い方ガイドとサポート』から";
        case 3:
          content = "お問い合わせやほしい機能はわせジュール公式サイトまで \n＞＞『使い方ガイドとサポート』から";
        case 4:
          content = "「このアプリいいね」と君が思うなら\n$todayは シェアだ記念日";
        //"友達とシェアして便利！「SNS共有コンテンツ」をチェック  \n＞＞『SNS共有コンテンツ』から";
        case 5:
          content = "カレンダーテンプレート機能で、いつもの予定を楽々登録！ \n＞＞『# タグとテンプレート』から";
        case 6:
          content = "カレンダーは複数日登録に対応！  \n＞＞『+』ボタンから";
        case 7:
          content = "予定配信機能で、グループの行事予定をシェア！！   \n＞＞『予定の配信/受信』から";
        case 8:
          content = "運営公式SNSで最新情報をチェック！  \n＞＞『サポート』から";
        case 9:
          content = "重要タスクやスケジュールは通知でお知らせ！ \n＞＞『設定』から";
        case 10:
          content = "毎日お疲れ様です！";
      }
    }

    return Padding(
        padding: EdgeInsets.only(
          top: SizeConfig.blockSizeHorizontal! * 2,
          bottom: SizeConfig.blockSizeHorizontal! * 1,
        ),
        child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HowToUsePage()),
              );
            },
            child: Container(
              width: SizeConfig.blockSizeHorizontal! * 95,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(12.5), // 角丸の半径を指定
              ),
              child: Padding(
                  padding: const EdgeInsets.only(
                      top: 2, left: 10, right: 10, bottom: 2),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: const TextStyle(
                              color: WHITE,
                              fontWeight: FontWeight.bold,
                              fontSize: 10),
                        ),
                        const Divider(color: WHITE, height: 2),
                        Text(
                          content,
                          style: const TextStyle(
                              color: WHITE, fontSize: 12.5),
                          overflow: TextOverflow.clip,
                        )
                      ])),
            )));
  }

  Widget doNotContainScreenShot(Widget target) {
    if (isScreenShotBeingTaken) {
      return const SizedBox();
    } else {
      return target;
    }
  }

  Widget publicContainScreenShot(Widget target, int isPublic) {
    bool boolIsPublic = true;
    if (isPublic == 0) {
      boolIsPublic = false;
    }

    if (boolIsPublic) {
      return target;
    } else {
      if (isScreenShotBeingTaken) {
        return const SizedBox();
      } else {
        return target;
      }
    }
  }

  Widget showOnlyScreenShot(Widget target) {
    if (isScreenShotBeingTaken) {
      return target;
    } else {
      return const SizedBox();
    }
  }

  BoxDecoration switchDecoration() {
    if (isScreenShotBeingTaken) {
      return const BoxDecoration(color: BACKGROUND_COLOR);
    } else {
      return const BoxDecoration(
        color: BACKGROUND_COLOR,
        //borderRadius: BorderRadius.circular(15.0), // 角丸の半径を指定
      );
    }
  }

  List<Map<DateTime, dynamic>> sortedMapList = [];
  Widget todaysScheduleListView() {
    List<Map<DateTime, dynamic>> sortedWidgetList = [];
    List<Map<DateTime, dynamic>> mapList = [];
    DateTime target = DateTime.now();
    final data = ref.read(calendarDataProvider);
    String targetKey = "${target.year}-${target.month.toString().padLeft(2, "0")}-${target.day.toString().padLeft(2, "0")}";
    List targetDayData = data.sortedDataByDay[targetKey] ?? [];
    DateTime targetDay = DateTime.parse(targetKey);
    DateTime now = DateTime.now();
    List<Map<DateTime, Widget>> mixedDataByTime = [];

    //まずは予定データの生成
    for (int index = 0; index < targetDayData.length; index++) {
      DateTime key = DateTime(now.year, now.month, now.day - 1, 0, 0, 0);
      if (targetDayData.elementAt(index)["startTime"].trim() != "") {
        DateFormat format = DateFormat.Hm();
        DateTime time =
            format.parse(targetDayData.elementAt(index)["startTime"]);
        key = DateTime(now.year, now.month, now.day, time.hour, time.minute, 0);
      }
      mapList.add({key: targetDayData.elementAt(index)});
    }

    //予定データが生成されたところに時間割データを混ぜる
    final timeTable = ref.read(timeTableProvider);
    // Map<dynamic, dynamic> timeTableData = timeTable.currentSemesterClasses;
    // int weekDay = targetDay.weekday;
    List<Map<String, dynamic>> targetDayList = timeTable.targetDateClasses(target);

    for (int i = 0; i < targetDayList.length; i++) {
      Map<String, dynamic> targetClass = targetDayList.elementAt(i);
      String startTime = timeTable.returnBeginningTime(targetClass["period"]);
      String endTime = timeTable.returnEndTime(targetClass["period"]);
      final newTargetClass = {
        ...targetClass,
        "startTime": startTime,
        "endTime":endTime
      };
      DateTime key = timeTable.returnBeginningDateTime(targetClass["period"]);
      mapList.add({key: newTargetClass});
    }

    //グチャグチャなMapデータをソートする
    sortedWidgetList = [];
    List<Map<DateTime, dynamic>> sortMapsByFirstKey(
        List<Map<DateTime, dynamic>> list) {
      list.sort((a, b) => a.keys.first.compareTo(b.keys.first));
      return list;
    }

    sortedMapList = sortMapsByFirstKey(mapList);

    //整えたMapデータをもとにウィジェットのリストを錬成
    for (int index = 0; index < sortedMapList.length; index++) {
      DateTime key = sortedMapList.elementAt(index).keys.first;
      Widget value = const SizedBox();
      if (sortedMapList.elementAt(index).values.first.containsKey("period")) {
        value = switchWidget(
            todaysClassChild(index),
            ConfigDataLoader()
                .searchConfigData("timetableInTodaysSchedule", ref));
        sortedWidgetList.add({key: value});
      } else {
        value = todaysScheduleChild(index, target);
        sortedWidgetList.add({key: value});
      }
    }

    if(sortedWidgetList.isEmpty) {
      return const SizedBox();
    } else {
      return Column(children: [
        menuList(
          Icons.calendar_month,
          "きょうの予定${DateFormat("   MM月dd日 (E)").format(DateTime.now())}",
          true,
          [
          Container(height:2,color:BACKGROUND_COLOR),
          ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              return sortedWidgetList.elementAt(index).values.first;
            },
            separatorBuilder: (context, index) {
              return Container(height:2,color:BACKGROUND_COLOR);
            },
            itemCount: sortedWidgetList.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          )
        ]),
        const SizedBox(height: 15)
      ]);
    }
  }

  Widget todaysScheduleChild(index, target) {
    Widget dateTimeData = Container();

    if (sortedMapList.elementAt(index).values.first["startTime"].trim() != "" &&
        sortedMapList.elementAt(index).values.first["endTime"] != "" &&
        sortedMapList.elementAt(index).values.first["endTime"] != null) {
      dateTimeData = Text(
        sortedMapList.elementAt(index).values.first["startTime"] +
            "\n" +
            sortedMapList.elementAt(index).values.first["endTime"],
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      );
    } else if (sortedMapList
            .elementAt(index)
            .values
            .first["startTime"]
            .trim() !=
        "") {
      dateTimeData = Text(
        sortedMapList.elementAt(index).values.first["startTime"],
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold),
      );
    } else {
      dateTimeData = Text(
        "終日",
        style: TextStyle(
            fontSize: SizeConfig.blockSizeHorizontal! * 3.5,
            fontWeight: FontWeight.bold),
      );
    }

    String formerDateTimeData = "終日";
    if (index != 0) {
      if (sortedMapList.elementAt(index - 1).values.first["startTime"].trim() !=
              "" &&
          sortedMapList.elementAt(index - 1).values.first["endTime"] != "" &&
          sortedMapList.elementAt(index - 1).values.first["endTime"] != null) {
        formerDateTimeData =
            sortedMapList.elementAt(index - 1).values.first["startTime"];
      } else if (sortedMapList
              .elementAt(index - 1)
              .values
              .first["startTime"]
              .trim() !=
          "") {
        formerDateTimeData =
            sortedMapList.elementAt(index - 1).values.first["startTime"];
      }
    }

    String thisDateTimeData = "終日";
    if (sortedMapList.elementAt(index).values.first["startTime"].trim() != "" &&
        sortedMapList.elementAt(index).values.first["endTime"] != "" &&
        sortedMapList.elementAt(index).values.first["endTime"] != null) {
      thisDateTimeData =
          sortedMapList.elementAt(index).values.first["startTime"];
    } else if (sortedMapList
            .elementAt(index)
            .values
            .first["startTime"]
            .trim() !=
        "") {
      thisDateTimeData =
          sortedMapList.elementAt(index).values.first["startTime"];
    }

    String nextDateTimeData = "終日";
    if (index + 1 < sortedMapList.length) {
      if (sortedMapList.elementAt(index + 1).values.first["startTime"].trim() !=
              "" &&
          sortedMapList.elementAt(index + 1).values.first["endTime"] != "" &&
          sortedMapList.elementAt(index + 1).values.first["endTime"] != null) {
        nextDateTimeData =
            sortedMapList.elementAt(index + 1).values.first["startTime"];
      } else if (sortedMapList
              .elementAt(index + 1)
              .values
              .first["startTime"]
              .trim() !=
          "") {
        nextDateTimeData =
            sortedMapList.elementAt(index + 1).values.first["startTime"];
      }
    }

    Color upperDividerColor = Colors.grey;
    Color dotColor = Colors.grey;
    Color underDividerColor = Colors.grey;
    DateTime now = DateTime.now();

    if (formerDateTimeData == "終日") {
      upperDividerColor = Colors.redAccent;
    } else {
      DateTime formerDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(formerDateTimeData.substring(0, 2)),
        int.parse(formerDateTimeData.substring(3, 5)),
      );
      if (formerDateTime.isBefore(now) && nextDateTimeData != "終日") {
        DateTime nextDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(nextDateTimeData.substring(0, 2)),
          int.parse(nextDateTimeData.substring(3, 5)),
        );
        upperDividerColor = Colors.red;
        if (nextDateTime.isBefore(now)) {
          underDividerColor = Colors.red;
        }
      }
    }

    if (thisDateTimeData == "終日") {
      upperDividerColor = Colors.red;
      dotColor = Colors.red;
      underDividerColor = Colors.red;
    } else {
      DateTime thisDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(thisDateTimeData.substring(0, 2)),
        int.parse(thisDateTimeData.substring(3, 5)),
      );
      if (thisDateTime.isBefore(now)) {
        upperDividerColor = Colors.red;
        dotColor = Colors.red;
        underDividerColor = Colors.red;
      }
      if (nextDateTimeData == "終日") {
        underDividerColor = Colors.grey;
      }
    }

    bool isLast = false;
    if (sortedMapList.length == index + 1) {
      isLast = true;
    }

    double dividerIndent = 0;
    if (isLast) {
      dividerIndent = 8;
    }

    Widget tagThumbnailer = const SizedBox();
    if (sortedMapList.elementAt(index).values.first["tagID"] != null &&
        sortedMapList.elementAt(index).values.first["tagID"] != "") {
      tagThumbnailer = Row(children: [
        tagThumbnail(sortedMapList.elementAt(index).values.first["tagID"]),
        Text(
          " ${returnTagTitle(
                  sortedMapList.elementAt(index).values.first["tagID"] ?? "",
                  ref)}",
          style: TextStyle(
              color: Colors.grey,
              fontSize: SizeConfig.blockSizeHorizontal! * 3,
              fontWeight: FontWeight.bold),
        )
      ]);
    }

    return taskListChild(
      Column(children: [
        IntrinsicHeight(
            child: Row(children: [
          Container(
            width: SizeConfig.blockSizeHorizontal! * 15,
            padding: EdgeInsets.only(
              left: SizeConfig.blockSizeHorizontal! * 2,
            ),
            child: Center(
              child: dateTimeData,
            ),
          ),
          SizedBox(
            width: 6,
            child: Column(children: [
              Expanded(
                child: VerticalDivider(
                  width: 2,
                  thickness: 2,
                  color: upperDividerColor,
                ),
              ),
              Container(
                height: 6,
                width: 6,
                decoration:
                    BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              Expanded(
                child: VerticalDivider(
                  width: 2,
                  thickness: 2,
                  color: underDividerColor,
                  endIndent: dividerIndent,
                ),
              )
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(12.5),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  tagThumbnailer,
                  SizedBox(
                    width: SizeConfig.blockSizeHorizontal! * 70,
                    child: Text(
                      " " +
                          sortedMapList
                              .elementAt(index)
                              .values
                              .first["subject"],
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                          color: BLACK,
                          fontSize: SizeConfig.blockSizeHorizontal! * 4.5,
                          fontWeight: FontWeight.bold),
                    ))
                ]),
          )
        ]))
      ]),
      () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return DailyViewPage(target: target);
            });
      },
      true,
      isLast,
    );
  }

  Widget todaysClassChild(index) {
    Widget dateTimeData = Text(
      sortedMapList.elementAt(index).values.first["startTime"] +
          "\n" +
          sortedMapList.elementAt(index).values.first["endTime"],
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
    );

    String formerDateTimeData = "終日";
    if (index != 0) {
      if (sortedMapList.elementAt(index - 1).values.first["startTime"].trim() !=
              "" &&
          sortedMapList.elementAt(index - 1).values.first["endTime"] != "" &&
          sortedMapList.elementAt(index - 1).values.first["endTime"] != null) {
        formerDateTimeData =
            sortedMapList.elementAt(index - 1).values.first["startTime"];
      } else if (sortedMapList
              .elementAt(index - 1)
              .values
              .first["startTime"]
              .trim() !=
          "") {
        formerDateTimeData =
            sortedMapList.elementAt(index - 1).values.first["startTime"];
      }
    }

    String thisDateTimeData =
        sortedMapList.elementAt(index).values.first["startTime"];

    String nextDateTimeData = "終日";
    if (index + 1 < sortedMapList.length) {
      if (sortedMapList.elementAt(index + 1).values.first["startTime"].trim() !=
              "" &&
          sortedMapList.elementAt(index + 1).values.first["endTime"] != "" &&
          sortedMapList.elementAt(index + 1).values.first["endTime"] != null) {
        nextDateTimeData =
            sortedMapList.elementAt(index + 1).values.first["startTime"];
      } else if (sortedMapList
              .elementAt(index + 1)
              .values
              .first["startTime"]
              .trim() !=
          "") {
        nextDateTimeData =
            sortedMapList.elementAt(index + 1).values.first["startTime"];
      }
    }

    Color upperDividerColor = Colors.grey;
    Color dotColor = Colors.grey;
    Color underDividerColor = Colors.grey;
    DateTime now = DateTime.now();

    if (formerDateTimeData == "終日") {
      upperDividerColor = Colors.redAccent;
    } else {
      DateTime formerDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(formerDateTimeData.substring(0, 2)),
        int.parse(formerDateTimeData.substring(3, 5)),
      );
      if (formerDateTime.isBefore(now) && nextDateTimeData != "終日") {
        DateTime nextDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(nextDateTimeData.substring(0, 2)),
          int.parse(nextDateTimeData.substring(3, 5)),
        );
        upperDividerColor = Colors.red;
        if (nextDateTime.isBefore(now)) {
          underDividerColor = Colors.red;
        }
      }
    }

    if (thisDateTimeData == "終日") {
      upperDividerColor = Colors.red;
      dotColor = Colors.red;
      underDividerColor = Colors.red;
    } else {
      DateTime thisDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(thisDateTimeData.substring(0, 2)),
        int.parse(thisDateTimeData.substring(3, 5)),
      );
      if (thisDateTime.isBefore(now)) {
        upperDividerColor = Colors.red;
        dotColor = Colors.red;
        underDividerColor = Colors.red;
      }
      if (nextDateTimeData == "終日") {
        underDividerColor = Colors.grey;
      }
    }

    bool isLast = false;
    if (sortedMapList.length == index + 1) {
      isLast = true;
    }

    double dividerIndent = 0;
    if (isLast) {
      dividerIndent = 8;
    }

    return GestureDetector(
      // onTap:()async{
      //   await showDialog(
      //     context: context,
      //     builder: (BuildContext context) {
      //       return CoursePreview(
      //         target: sortedMapList.elementAt(index).values.first,
      //         setTimetableState: setState,
      //         taskList: const [],
      //     );
      //   });
      // },
      child:taskListChild(
        Column(children: [
          IntrinsicHeight(
              child: Row(children: [
            Container(
              width: SizeConfig.blockSizeHorizontal! * 15,
              padding: EdgeInsets.only(
                left: SizeConfig.blockSizeHorizontal! * 2,
              ),
              child: Center(
                child: dateTimeData,
              ),
            ),
            SizedBox(
              width: 6,
              child: Column(children: [
                Expanded(
                  child: VerticalDivider(
                    width: 2,
                    thickness: 2,
                    color: upperDividerColor,
                  ),
                ),
                Container(
                  height: 6,
                  width: 6,
                  decoration:
                      BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
                Expanded(
                  child: VerticalDivider(
                    width: 2,
                    thickness: 2,
                    color: underDividerColor,
                    endIndent: dividerIndent,
                  ),
                )
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(12.5),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(children: [
                      Icon(
                        Icons.school,
                        color: MAIN_COLOR,
                        size: SizeConfig.blockSizeHorizontal! * 3,
                      ),
                      Text(
                          "${ref.read(timeTableProvider).intToWeekday(sortedMapList
                                  .elementAt(index)
                                  .values
                                  .first["weekday"])}の授業、",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: SizeConfig.blockSizeHorizontal! * 3,
                              fontWeight: FontWeight.bold)),
                      Text(
                          sortedMapList
                              .elementAt(index)
                              .values
                              .first["classRoom"],
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: SizeConfig.blockSizeHorizontal! * 3)),
                    ]),
                    SizedBox(
                        width: SizeConfig.blockSizeHorizontal! * 65,
                        child: Text(
                          " " +
                              sortedMapList
                                  .elementAt(index)
                                  .values
                                  .first["courseName"],
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                              color: BLACK,
                              fontSize: SizeConfig.blockSizeHorizontal! * 4.5,
                              fontWeight: FontWeight.bold),
                        ))
                  ]),
            )
          ]))
        ]),
        () {},
        true,
        isLast,
      )
    );
  }

  Widget taskDataListList(int fromNow) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    Widget noneTaskWidget = const SizedBox();

    if (isTaskDatanull(today)) {
      noneTaskWidget = taskListChild(
          Column(children: [
            const SizedBox(height: 5),
            Text(
              "  $fromNow日以内の課題はありません。",
              style: TextStyle(
                color: Colors.grey,
                fontSize: SizeConfig.blockSizeHorizontal! * 5,
              ),
            ),
            const SizedBox(height: 5),
          ]),
          () {},
          true,
          true);
    }

    if (fromNow == 0) {
      return const SizedBox();
    } else {
      return Column(children: [
        menuList(Icons.check, "近日締切の課題", true, [
          Container(height:2,color:BACKGROUND_COLOR),
          noneTaskWidget,
          ListView.separated(
            itemBuilder: (context, index) {
              DateTime targetDay = today.add(Duration(days: index));
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [taskDataList(targetDay, index)]);
            },
            separatorBuilder: (context, index) {
              return Container(height:2,color:BACKGROUND_COLOR);
            },
            itemCount: fromNow,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
        ]),
        const SizedBox(height: 20)
      ]);
    }
  }

  Widget taskDataList(DateTime target, int fromNow) {
    final taskData = ref.watch(taskDataProvider);
    Map<DateTime, List<Map<String, dynamic>>> sortedData =
        taskData.sortDataByDtEnd(taskData.taskDataList);
    Widget title = const SizedBox();
    String indexText = "";

    if (fromNow == 0) {
      indexText = "今日まで";
    } else {
      indexText = "$fromNow日後";
    }

    if (sortedData.keys.contains(target)) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        title,
        taskListHeader(indexText, fromNow),
        ListView.separated(
          separatorBuilder: (context, index) {
            return Container(height:2,color:BACKGROUND_COLOR);
          },
          itemBuilder: (BuildContext context, int index) {
            String timeEnd = DateFormat("HH:mm").format(
                DateTime.fromMillisecondsSinceEpoch(
                    sortedData[target]!.elementAt(index)["dtEnd"]));

            Widget dateTimeData = Container();
            dateTimeData = Text(
              sortedData[target]!.elementAt(index)["title"],
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: SizeConfig.blockSizeHorizontal! * 3,
                  fontWeight: FontWeight.bold),
            );

            bool isLast = false;
            if (sortedData[target]!.length == index + 1) {
              isLast = true;
            }
            double dividerIndent = 0;
            if (isLast) {
              dividerIndent = 8;
            }

            Color upperDividerColor = Colors.grey;
            Color dotColor = Colors.grey;
            Color underDividerColor = Colors.grey;

            DateTime now = DateTime.now();

            DateTime thisDateTimeData = DateTime.fromMillisecondsSinceEpoch(
                sortedData[target]!.elementAt(index)["dtEnd"]);
            DateTime formerDateTimeData = DateTime(thisDateTimeData.year,
                thisDateTimeData.month, thisDateTimeData.day - 1);
            DateTime nextDateTimeData = DateTime(
              thisDateTimeData.year,
              thisDateTimeData.month,
              thisDateTimeData.day + 1,
            );

            if (index != 0) {
              formerDateTimeData = DateTime.fromMillisecondsSinceEpoch(
                  sortedData[target]!.elementAt(index - 1)["dtEnd"]);
            }

            if (index + 1 < sortedData[target]!.length) {
              nextDateTimeData = DateTime.fromMillisecondsSinceEpoch(
                  sortedData[target]!.elementAt(index + 1)["dtEnd"]);
            }

            if (thisDateTimeData.isBefore(now)) {
              upperDividerColor = Colors.red;
              dotColor = Colors.red;
              underDividerColor = Colors.red;
            } else if (formerDateTimeData.isBefore(now) &&
                fromNow == 0 &&
                index == 0) {
              upperDividerColor = Colors.red;
            } else if (formerDateTimeData.isBefore(now)) {
              upperDividerColor = Colors.grey;
            }

            if (isLast) {
              underDividerColor = Colors.grey;
            }

            return taskListChild(
                IntrinsicHeight(
                    child: Row(children: [
                  Container(
                      width: SizeConfig.blockSizeHorizontal! * 15,
                      padding: EdgeInsets.only(
                        left: SizeConfig.blockSizeHorizontal! * 2,
                      ),
                      child: Text(timeEnd,
                          style: TextStyle(
                            fontSize: SizeConfig.blockSizeHorizontal! * 4,
                            fontWeight: FontWeight.bold,
                          ))),
                  SizedBox(
                    width: 6,
                    child: Column(children: [
                      Expanded(
                        child: VerticalDivider(
                          width: 2,
                          thickness: 2,
                          color: upperDividerColor,
                        ),
                      ),
                      Container(
                        height: 6,
                        width: 6,
                        decoration: BoxDecoration(
                            color: dotColor, shape: BoxShape.circle),
                      ),
                      Expanded(
                        child: VerticalDivider(
                          width: 2,
                          thickness: 2,
                          color: underDividerColor,
                          endIndent: dividerIndent,
                        ),
                      )
                    ]),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.5),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            dateTimeData,
                            Text(
                              sortedData[target]!.elementAt(index)["summary"] ??
                                  "(詳細なし)",
                              style: TextStyle(
                                  color: BLACK,
                                  fontSize: SizeConfig.blockSizeHorizontal! * 4.5,
                                  fontWeight: FontWeight.bold),
                            )
                          ]),
                    ),
                  )
              ])), 
              () async{
              // await bottomSheet(context,sortedData[target]!.elementAt(index),setState).then(
              //   (value) async{
              //     ref.read(taskDataProvider).isRenewed = true;
              //     ref.read(calendarDataProvider.notifier)
              //       .state = CalendarData();
              //     while (
              //         ref.read(taskDataProvider).isRenewed !=
              //             false) {
              //     await Future.delayed(
              //           const Duration(microseconds: 1));
              //     }
              // });
              },
             isLast, isLast);
          },
          itemCount: sortedData[target]!.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        )
      ]);
    } else {
      if (fromNow == 0 && !isTaskDatanull(target)) {
        title = const SizedBox();
      }

      return title;
    }
  }

  bool isTaskDatanull(DateTime target) {
    int numOfTasks = ConfigDataLoader().searchConfigInfo("taskList", ref);
    bool result = true;
    final taskData = ref.watch(taskDataProvider);
    Map<DateTime, List<Map<String, dynamic>>> sortedData =
        taskData.sortDataByDtEnd(taskData.taskDataList);
    for (int i = 0; i < numOfTasks; i++) {
      if (sortedData[target.add(Duration(days: i))] != null) {
        result = false;
      }
    }
    return result;
  }


  Widget loadArbeitStatsPreview(targetMonth) {
    return FutureBuilder(
      future: ref.read(calendarDataProvider).sortDataByMonth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
              height: 200,
              child:
                  Center(child: CircularProgressIndicator(color: MAIN_COLOR)));
        } else {
          return switchWidget(arbeitStatsPreview(targetMonth),
              ConfigDataLoader().searchConfigData("arbeitPreview", ref));
        }
      },
    );
  }

  Widget arbeitStatsPreview(targetMonth) {
    String year = targetMonth.substring(0, 4);
    String month = targetMonth.substring(5, 7);
    String targetKey = "$year-$month";
    TextStyle titletyle = TextStyle(
        color: Colors.grey, fontSize: SizeConfig.blockSizeHorizontal! * 4);
    TextStyle previewStyle = TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: SizeConfig.blockSizeHorizontal! * 6);
    Duration workTimeSum =
        ArbeitCalculator().monthlyWorkTimeSumOfAllTags(targetKey, ref);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            Text("$year年 推計年収", style: titletyle),
            const Divider(height: 1,color:Colors.transparent),
            Text(
                "${ArbeitCalculator().formatNumberWithComma(ArbeitCalculator()
                        .yearlyWageSumWithAdditionalWorkTime(
                            targetMonth, ref))} 円",
                style: previewStyle),
          ])),
      Container(height:2,color:BACKGROUND_COLOR),
      IntrinsicHeight(
        child: Row(children: [
          Expanded(
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(children: [
                  Text("$month月 推計月収", style: titletyle),
                  
                  Text(
                      "${ArbeitCalculator().formatNumberWithComma(
                              ArbeitCalculator()
                                      .monthlyWageSum(targetMonth, ref) +
                                  ArbeitCalculator()
                                      .monthlyFeeSumOfAllTags(targetKey, ref))} 円",
                      style: previewStyle),
                ])),
          ),
          const VerticalDivider(width: 2,thickness:2,color:BACKGROUND_COLOR),
          Expanded(
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(children: [
                  Text("$month月  労働時間合計", style: titletyle),
                  
                  Text(
                      "${workTimeSum.inHours}時間${workTimeSum.inMinutes % 60} 分",
                      style: previewStyle),
                ])),
          ),
        ]),
      ),
      //const Divider(height: 1),
    ]);
  }
}

Widget calendarIcon(Color color, double size) {
  return Icon(Icons.calendar_month, color: color, size: size);
}

Widget taskIcon(Color color, double size) {
  return Icon(Icons.check, color: color, size: size);
}

Widget scheduleEmptyFlag(WidgetRef ref, Widget widget) {
  if (ref.read(calendarDataProvider).calendarData.isEmpty) {
    return const SizedBox();
  } else {
    return widget;
  }
}

Widget tagEmptyFlag(WidgetRef ref, Widget widget) {
  if (ref.read(calendarDataProvider).tagData.isEmpty) {
    return const SizedBox();
  } else {
    return widget;
  }
}

Widget templateEmptyFlag(WidgetRef ref, Widget widget) {
  if (ref.read(calendarDataProvider).templateData.isEmpty) {
    return const SizedBox();
  } else {
    return widget;
  }
}
