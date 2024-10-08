import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_calandar_app/backend/DB/sharepreference.dart';
import 'package:flutter_calandar_app/static/converter.dart';
import 'package:flutter_calandar_app/static/constant.dart';
import 'package:flutter_calandar_app/frontend/assist_files/data_loader.dart';
import 'package:flutter_calandar_app/frontend/screens/common/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/common/logo_and_title.dart';
import 'package:flutter_calandar_app/frontend/screens/common/tutorials.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/timetable/timetable_data_manager.dart';
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
import 'package:flutter_calandar_app/frontend/screens/calendar_page/arbeit_stats_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/how_to_use_page.dart';
import 'package:flutter_calandar_app/frontend/screens/setting_page/setting_page.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/daily_view_sheet.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_data_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../assist_files/size_config.dart';
import 'add_event_dialog.dart';

import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:async';

import '../../../backend/notify/notify_setting.dart';
import "../../../backend/DB/handler/my_course_db.dart";

var random = Random(DateTime.now().millisecondsSinceEpoch);
var randomNumber = random.nextInt(10); // 0から10までの整数を生成

class Calendar extends ConsumerStatefulWidget {
  Function(int) movePage;
  Calendar({
    required this.movePage,
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
  final ScrollController controller = ScrollController();
  bool _isFabVisible = true;

  late bool isScreenShotBeingTaken;
  late String targetMonth = "";
  String thisMonth =
      "${DateTime.now().year}/${DateTime.now().month.toString().padLeft(2, '0')}";
  String today =
      "${DateTime.now().year}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().day.toString().padLeft(2, '0')}";
  late int thisYear;
  late int semestNum;
  late Term? currentSemester;
  late Term? currentQuarter;

  @override
  void initState() {
    super.initState();

    initTargetSem();
    LocalNotificationSetting().requestIOSPermission();
    LocalNotificationSetting().requestAndroidPermission();
    LocalNotificationSetting().initializePlatformSpecifics(context);
    displayDB();
    targetMonth = thisMonth;
    generateCalendarData();
    _initializeData();
    isScreenShotBeingTaken = false;
    controller.addListener(_onScroll);
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

  void _onScroll() {
    // スクロールの方向に応じてFABを表示・非表示にする
    if (controller.position.userScrollDirection == ScrollDirection.reverse) {
      // 下方向にスクロールした場合
      if (_isFabVisible) {
        setState(() {
          _isFabVisible = false;  // FABを非表示
        });
      }
    } else if (controller.position.userScrollDirection == ScrollDirection.forward) {
      // 上方向にスクロールした場合
      if (!_isFabVisible) {
        setState(() {
          _isFabVisible = true;  // FABを表示
        });
      }
    }
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
    SharepreferenceHandler sharepreferenceHandler = SharepreferenceHandler();
    if (sharepreferenceHandler.getValue(SharepreferenceKeys.hasCompletedIntro)
            as bool !=
        true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const IntroPage(),
          fullscreenDialog: true,
        ),
      );
      //pref.setBool('hasCompletedIntro', true);
    } else if (sharepreferenceHandler
            .getValue(SharepreferenceKeys.hasCompletedCalendarIntro) !=
        true) {
      showScheduleGuide(context);
      sharepreferenceHandler.setValue(
          SharepreferenceKeys.hasCompletedCalendarIntro, true);
    }
  }

  void initTargetSem() {
    DateTime now = DateTime.now();
    thisYear = Term.whenSchoolYear(now);

    currentQuarter = Term.whenQuarter(now);
    currentSemester = Term.whenSemester(now);
    if (currentQuarter == null) {
      if (now.month == 1) {
        currentQuarter = Term.winterQuarter;
      } else if (now.month == 4 || now.month == 5) {
        currentQuarter = Term.springQuarter;
      } else if (now.month == 6 || now.month == 7) {
        currentQuarter = Term.summerQuarter;
      } else if (now.month == 10 || now.month == 11) {
        currentQuarter = Term.fallQuarter;
      } else if (now.month == 12) {
        currentQuarter = Term.winterQuarter;
      } else {
        currentQuarter == null;
      }
    }

    if (now.month <= 3) {
      thisYear -= 1;
    }
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
        .getData();
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

    return Scaffold(
        backgroundColor: BACKGROUND_COLOR,
        body: CustomScrollView(
        controller: controller,
        slivers: <Widget>[
          SliverAppBar(
            // ピン留めオプション。true にすると AppBar はスクロールで画面上に固定される
            floating: true,
            pinned: false,
            snap: true,
            collapsedHeight: 80,
            expandedHeight: 80,
            // AppBar の拡張部分 (スクロール時に表示される)
            flexibleSpace: calendarHeader(),
          ),
           SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Column(children: [
                  Padding(
                    padding: EdgeInsets.only(
                     left: SizeConfig.blockSizeHorizontal! * 0, //2.5,
                      right: SizeConfig.blockSizeHorizontal! * 0,
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
                        ref.read(taskDataProvider).getData(taskData);
                        ref.read(calendarDataProvider).getData(snapshot.data!);
                        ref.read(calendarDataProvider).sortDataByDay();
                        ref.read(timeTableProvider).sortDataByWeekDay(
                        ref.read(timeTableProvider).timeTableDataList);
                        ref.read(timeTableProvider)
                            .initUniversityScheduleByDay(thisYear, [
                          if (currentQuarter != null) currentQuarter!,
                          if (currentSemester != null) currentSemester!,
                          Term.fullYear,
                        ]);
                        return calendarBody();
                      }
                    },
                  ),
                ),
              ],
            );
          },
          // リストアイテムの数
          childCount: 1,
          ),
        )
      ]),
        floatingActionButton: 
          AnimatedOpacity(
            opacity: _isFabVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 600),
            child: Container(
              child: Row(children: [
                const Spacer(),
                const AddEventButton(),
                const SizedBox(width: 10),
                calendarShareButton(context),
              ])
          )
        )
      );
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

  Widget calendarHeader(){
    return Container(
      decoration: BoxDecoration(
        color: FORGROUND_COLOR,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 2,
            offset: const Offset(0, 0),
          ),
        ]
      ),
      child: Column(children:[
        Row(children: [
          IconButton(
              onPressed: () {
                decreasePgNumber();
              },
              icon: const Icon(Icons.arrow_back_ios),
              iconSize: 20,
              color: BLUEGREY),
          Text(
            targetMonth,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
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
          doNotContainScreenShot(
            scheduleEmptyFlag(
            ref,
            Container(
              width: 160,
              height: 35,
              decoration: BoxDecoration(
                color: BLUEGREY,
                borderRadius: BorderRadius.circular(5)
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const TagAndTemplatePage()),
                  );
                },
                child:Row(children:[
                  const Spacer(),
                  Icon(Icons.tag,
                    size: 19, color: FORGROUND_COLOR),
                  const SizedBox(width: 2),
                  Text('タグとテンプレート',
                    style: TextStyle(
                        fontSize: 12.5,
                        color: FORGROUND_COLOR,
                        fontWeight: FontWeight.normal)),
                  const Spacer()
                ])
                ),
              ),
            ),
          ),
          showOnlyScreenShot(LogoAndTitle(size: 7,logotype: AppLogoType.calendar,)),
          const SizedBox(width: 10)
        ]),
        doNotContainScreenShot(
          Row(children:[
            simpleSmallButton(
              "年間行事予定の取得",
              (){
                widget.movePage(2);
              }),
              const Spacer()
        ])),
      ])
    );
  }

  Widget calendarBody() {
    generateHoliday();
    return Column(children: [
      Screenshot(
          controller: _screenShotController,
          child: Column(children: [
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
          ])),
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
                          builder: (_) => ArbeitStatsPage(
                                targetMonth: targetMonth,
                                isAppbar: true,
                              )));
                },
                child: menuList(
                    Icons.currency_yen,
                    "",
                    false,
                    [
                      menuListChild(Icons.currency_yen, "アルバイト", () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ArbeitStatsPage(
                                    targetMonth: targetMonth, isAppbar: true)));
                      }),
                      loadArbeitStatsPreview(targetMonth)
                    ],
                    showIcon: false))),
        const SizedBox(height: 15),
        // menuListChild(Icons.settings, "設定", () {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => SettingsPage()),
        //   );
        // }),
        // menuListChild(Icons.info, "サポート", () {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => SnsLinkPage(showAppBar: true)),
        //   );
        // }),
        const SizedBox(height: 100),
      ])
    ]);
  }

  Widget calendarShareButton(BuildContext context) {
    return FloatingActionButton(
        heroTag: "calendar_2",
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
    if (currentQuarter == null) {
      if (month == 1) {
        currentQuarter = Term.winterQuarter;
      } else if (month == 4 || month == 5) {
        currentQuarter = Term.springQuarter;
      } else if (month == 6 || month == 7) {
        currentQuarter = Term.summerQuarter;
      } else if (month == 10 || month == 11) {
        currentQuarter = Term.fallQuarter;
      } else if (month == 12) {
        currentQuarter = Term.winterQuarter;
      } else {
        currentQuarter == null;
      }
    }
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
              style:
                  const TextStyle(color: BLUEGREY, fontWeight: FontWeight.bold),
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

  double calendarCellWidth = SizeConfig.blockSizeHorizontal! * 14.285;
  double calendarCellsHeight = SizeConfig.blockSizeVertical! * 14;

  Widget generateCalendarCells(String dayOfWeek) {
    return SizedBox(
        width: SizeConfig.blockSizeHorizontal! * 14.285,
        child: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: ListView.builder(
            itemBuilder: (context, index) {
            DateTime target =
                generateCalendarData()[dayOfWeek]!.elementAt(index);
            return InkWell(
              child: Container(
                  width: calendarCellWidth,
                  height: calendarCellsHeight,
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
                              child: Text(target.day.toString(),
                                  style: TextStyle(
                                      color: dateColour(target),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15))),
                          const Spacer(),
                          doNotContainScreenShot(
                              taskListLength(target, calendarCellWidth / 8)),
                          const SizedBox(width: 3)
                        ]),
                        Expanded(child: calendarCellsChild(target)),
                        holidayName(target),
                      ])),
              onTap: () async{
                await showModalBottomSheet(
                  isScrollControlled: true,
                  isDismissible: true,
                  enableDrag: true,
                  backgroundColor: FORGROUND_COLOR,
                  context: context,
                  builder: (BuildContext context) {
                    return DailyViewSheet(target: target);
                  });
              },
            );
          },
          itemCount: generateCalendarData()[dayOfWeek]!.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
        )
      )
    );
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
      return const Color.fromARGB(255, 255, 215, 215);
    } else if (target.weekday == 6 &&
        ConfigDataLoader().searchConfigData("holidayPaint", ref) == 1) {
      return const Color.fromARGB(255, 225, 225, 255);
    } else if (target.weekday == 7 &&
        ConfigDataLoader().searchConfigData("holidayPaint", ref) == 1) {
      return const Color.fromARGB(255, 255, 215, 215);
    } else {
      return FORGROUND_COLOR;
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
      return lighten(cellColour(target), 0.03);
    } else if (target.weekday == 6 &&
        ConfigDataLoader().searchConfigData("holidayPaint", ref) == 1) {
      return lighten(cellColour(target), 0.03);
    } else if (target.weekday == 7 &&
        ConfigDataLoader().searchConfigData("holidayPaint", ref) == 1) {
      return lighten(cellColour(target), 0.03);
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
                color: FORGROUND_COLOR,
                fontSize: fontSize),
          ));
    }
  }

  Widget calendarCellsChild(DateTime target) {
    final data = ref.read(calendarDataProvider);
    String targetKey =
        "${target.year}-${target.month.toString().padLeft(2, "0")}-${target.day.toString().padLeft(2, "0")}";
    List targetDayData = data.sortedDataByDay[targetKey] ?? [];
    List<Map<DateTime, Widget>> mixedDataByTime = [];

    //まずは予定データの生成
    for (int index = 0; index < targetDayData.length; index++) {
      DateTime key = DateFormat("HH:mm").parse("00:00");

      if (targetDayData.elementAt(index)["startTime"].trim() != "") {
        key = DateFormat("HH:mm")
            .parse(targetDayData.elementAt(index)["startTime"]);
      }

      Widget value = const SizedBox();
      value = scheduleListChild(targetDayData, index, target);

      mixedDataByTime.add({key: value});
    }

    //予定データが生成されたところに時間割データを混ぜる
    final timeTable = ref.read(timeTableProvider);
    List<MyCourse> targetDayList = timeTable.targetDateClasses(target);
    if (targetDayList.isNotEmpty) {
      MyCourse firstClass = targetDayList.first;
      MyCourse lastClass = targetDayList.last;
      DateTime? startTime = firstClass.period?.start;
      DateTime? endTime = lastClass.period?.end;
      if (startTime != null && endTime != null) {
        String universityClassData =
            "${DateFormat("HH:mm").format(startTime)}~${DateFormat("HH:mm").format(endTime)}";
        Widget value = switchWidget(classListChild(universityClassData, target),
            ConfigDataLoader().searchConfigData("timetableInDailyView", ref));

        mixedDataByTime.add({startTime: value});
      }
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
            itemCount: sortedList.length,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics()));
  }

  Widget scheduleListChild(targetDayData, index, target) {
    double fontSize = calendarCellsHeight / 18;
    Widget dateTimeData = Container();
    if (targetDayData.elementAt(index)["startTime"].trim() != "" &&
        targetDayData.elementAt(index)["endTime"].trim() != "") {
      dateTimeData = Text(
        "${" " + targetDayData.elementAt(index)["startTime"]}～" +
            targetDayData.elementAt(index)["endTime"],
        style: TextStyle(color: Colors.grey, fontSize: fontSize),
      );
    } else if (targetDayData.elementAt(index)["startTime"].trim() != "") {
      dateTimeData = Text(
        " " + targetDayData.elementAt(index)["startTime"],
        style: TextStyle(color: Colors.grey, fontSize: fontSize),
      );
    } else {
      dateTimeData = Text(
        " 終日",
        style: TextStyle(color: Colors.grey, fontSize: fontSize),
      );
    }
    return publicContainScreenShot(
        SizedBox(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Align(alignment: Alignment.centerLeft, child: dateTimeData),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            tagThumbnail(targetDayData.elementAt(index)["tagID"]),
            Flexible(
              child: Text(
                " " + targetDayData.elementAt(index)["subject"],
                style:
                    TextStyle(color: BLACK, fontSize: calendarCellsHeight / 16),
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
              color: cellChildColour(target))
        ])),
        targetDayData.elementAt(index)["isPublic"]);
  }

  Widget classListChild(String universityClassData, target) {
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
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: calendarCellsHeight / 18)),
                    Row(children: [
                      Icon(Icons.school,
                          color: MAIN_COLOR, size: calendarCellsHeight / 16),
                      Text(" 授業",
                          style: TextStyle(
                              color: BLACK,
                              fontSize: calendarCellsHeight / 16)),
                    ]),
                    Divider(
                      height: 2,
                      indent: 2.75,
                      endIndent: 2.75,
                      thickness: 2,
                      color: cellChildColour(target),
                    )
                  ])),
          ConfigDataLoader().searchConfigData("timetableInCalendarcell", ref));
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
          Container(
              width: calendarCellsHeight / 30,
              height: calendarCellsHeight / 14,
              color: returnTagColor(id, ref))
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
          color: FORGROUND_COLOR,
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
          color: FORGROUND_COLOR,
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
              decoration: roundedBoxdecoration(radiusType: 2),
              width: SizeConfig.blockSizeHorizontal! * 95,
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Center(
                  child: Row(children: [
                const SizedBox(width: 20),
                Icon(icon, color: MAIN_COLOR, size: 40),
                const Spacer(),
                Text(text,
                    style: const TextStyle(
                      fontSize: 20,
                    )),
                const Spacer(),
              ]))),
          Container(height: 2, color: BACKGROUND_COLOR)
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
              decoration:
                  BoxDecoration(color: FORGROUND_COLOR, borderRadius: radius),
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
          height: 23,
          color: FORGROUND_COLOR,
          child: Center(
              child: Row(children: [
            const SizedBox(width: 10),
            Container(width: 8, height: 17, color: accentColor),
            const SizedBox(width: 5),
            Text(text,
                style: const TextStyle(
                    fontSize: 15, color: BLACK, fontWeight: FontWeight.bold)),
            const Spacer(),
          ]))),
      Divider(
          height: 2,
          thickness: 2,
          indent: 10,
          endIndent: 10,
          color: BACKGROUND_COLOR)
    ]);
  }

  Widget menuList(IconData headerIcon, String headerText, bool showCustomButton,
      List<Widget> child,
      {bool showIcon = true}) {
    Widget customButton = const SizedBox();
    if (showCustomButton) {
      customButton = InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          },
          child: const Icon(Icons.settings, size: 20, color: Colors.grey));
    }
    Widget icon = const SizedBox();
    if (showIcon) {
      icon = Icon(headerIcon, size: 18, color: Colors.grey);
    }

    return Container(
        width: SizeConfig.blockSizeHorizontal! * 95,
        decoration: BoxDecoration(
          color: FORGROUND_COLOR,
          borderRadius: BorderRadius.circular(20), // 角丸の半径を指定
        ),
        child: Column(children: [
          SizedBox(
              height: 25,
              child: Row(children: [
                const SizedBox(width: 15),
                icon,
                Text(
                  " $headerText",
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const Spacer(),
                customButton,
                const SizedBox(width: 20),
              ])),
          MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child:ListView.builder(
              itemBuilder: (context, index) {
                return child.elementAt(index);
              },
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: child.length,
          )),
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
                          style: TextStyle(
                              color: FORGROUND_COLOR,
                              fontWeight: FontWeight.bold,
                              fontSize: 10),
                        ),
                        Divider(color: FORGROUND_COLOR, height: 2),
                        Text(
                          content,
                          style:
                              TextStyle(color: FORGROUND_COLOR, fontSize: 12.5),
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
      return BoxDecoration(color: BACKGROUND_COLOR);
    } else {
      return BoxDecoration(
        color: BACKGROUND_COLOR);
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
    TextStyle titletyle = const TextStyle(color: Colors.grey, fontSize: 17);
    TextStyle previewStyle =
        const TextStyle(fontWeight: FontWeight.bold, fontSize: 22);
    Duration workTimeSum =
        ArbeitCalculator().monthlyWorkTimeSumOfAllTags(targetKey, ref);

    return 
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            Text("$year年 推計年収", style: titletyle),
            const Divider(height: 1, color: Colors.transparent),
            Text(
                "${ArbeitCalculator().formatNumberWithComma(ArbeitCalculator().yearlyWageSumWithAdditionalWorkTime(targetMonth, ref))} 円",
                style: previewStyle),
          ])),
      Container(height: 2, color: BACKGROUND_COLOR),
      IntrinsicHeight(
        child: Row(children: [
          Expanded(
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(children: [
                  Text("$month月 推計月収", style: titletyle),
                  Text(
                      "${ArbeitCalculator().formatNumberWithComma(ArbeitCalculator().monthlyWageSum(targetMonth, ref) + ArbeitCalculator().monthlyFeeSumOfAllTags(targetKey, ref))} 円",
                      style: previewStyle),
                ])),
          ),
          VerticalDivider(width: 2, thickness: 2, color: BACKGROUND_COLOR),
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
