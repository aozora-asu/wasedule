import 'package:flutter_calandar_app/frontend/assist_files/data_loader.dart';
import 'package:flutter_calandar_app/frontend/screens/common/logo_and_title.dart';
import 'package:flutter_calandar_app/frontend/screens/common/tutorials.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/data_backup_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/schedule_broadcast_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/sns_contents_page/sns_contents_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/university_schedule.dart';
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
import 'package:flutter_calandar_app/frontend/screens/task_page/data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/daily_view_page.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/schedule_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/url_register_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../assist_files/size_config.dart';
import 'add_event_button.dart';

import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:async';

import '../../../backend/notify/notify_setting.dart';
import '../../../backend/DB/models/notify_content.dart';
import '../../../backend/notify/notify.dart';

var random = Random(DateTime.now().millisecondsSinceEpoch);
var randomNumber = random.nextInt(10); // 0から10までの整数を生成

class Calendar extends ConsumerStatefulWidget {
  const Calendar({
    Key? key,
  }) : super(key: key);
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
  String thisMonth = DateTime.now().year.toString() +
      "/" +
      DateTime.now().month.toString().padLeft(2, '0');
  String today = DateTime.now().year.toString() +
      "/" +
      DateTime.now().month.toString().padLeft(2, '0') +
      "/" +
      DateTime.now().day.toString().padLeft(2, '0');

  @override
  void initState() {
    super.initState();
    displayDB();
    LocalNotificationSetting().requestIOSPermission();
    LocalNotificationSetting().requestAndroidPermission();
    LocalNotificationSetting().initializePlatformSpecifics();
    NotifyContent().taskDueTodayNotification();
    NotifyContent().scheduleDailyEightAMNotification();

    // NotifyContent().sampleNotification("task");
    // NotifyContent().sampleNotification("schedule");
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
    final addData = await databaseHelper.taskListForTaskPage();
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

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTutorial(context);
    });

    ref.watch(calendarDataProvider);
    SizeConfig().init(context);
    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: calendarBackGroundImage(),
            fit: BoxFit.cover,
          )),
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: SizeConfig.blockSizeHorizontal! * 2.5,
                  right: SizeConfig.blockSizeHorizontal! * 2.5,
                ),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: CalendarDataLoader().getDataSource(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // データが取得される間、ローディングインディケータを表示できます。
                      ConfigDataLoader().initConfig(ref);
                      ref
                          .read(calendarDataProvider)
                          .getTagData(TagDataLoader().getTagDataSource());
                      ref.read(calendarDataProvider).getConfigData(
                          ConfigDataLoader().getConfigDataSource());
                      return calendarBody();
                    } else if (snapshot.hasError) {
                      // エラーがある場合
                      return const SizedBox();
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      if (ref.read(taskDataProvider).isRenewed) {
                        displayDB();
                        _getTemplateDataSource();
                        ref
                            .read(calendarDataProvider)
                            .getArbeitData(_getArbeitDataSource());
                        ref.read(calendarDataProvider).sortDataByDay();
                        ref
                            .read(calendarDataProvider)
                            .getTemplateData(_getTemplateDataSource());
                        ref.read(taskDataProvider).isRenewed = false;
                      }

                      ref
                          .read(calendarDataProvider)
                          .getArbeitData(_getArbeitDataSource());
                      ref
                          .read(calendarDataProvider)
                          .getTagData(TagDataLoader().getTagDataSource());
                      ref
                          .read(calendarDataProvider)
                          .getTemplateData(_getTemplateDataSource());
                      ref.read(calendarDataProvider).sortDataByDay();

                      return calendarBody();
                    } else {
                      if (ref.read(taskDataProvider).isRenewed) {
                        //ConfigData().initConfig(ref);
                        displayDB();
                        _getTemplateDataSource();
                        ref.read(calendarDataProvider).getConfigData(
                            ConfigDataLoader().getConfigDataSource());
                        ref
                            .read(calendarDataProvider)
                            .getArbeitData(_getArbeitDataSource());
                        ref
                            .read(calendarDataProvider)
                            .getTemplateData(_getTemplateDataSource());
                        ref.read(calendarDataProvider).getData(snapshot.data!);
                        ref.read(calendarDataProvider).sortDataByDay();
                        ref.read(taskDataProvider).isRenewed = false;
                      }
                      ref
                          .read(calendarDataProvider)
                          .getArbeitData(_getArbeitDataSource());
                      ref
                          .read(calendarDataProvider)
                          .getTagData(TagDataLoader().getTagDataSource());
                      ref
                          .read(calendarDataProvider)
                          .getTemplateData(_getTemplateDataSource());
                      ref.read(calendarDataProvider).getData(snapshot.data!);
                      ref.read(calendarDataProvider).sortDataByDay();
                      ref.read(taskDataProvider).getData(taskData);

                      return calendarBody();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Row(children: [
          const Spacer(),
          AddEventButton(),
          const SizedBox(width: 10),
          calendarShareButton(context),
        ]));
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
      Row(children: [
        const Spacer(),
        Padding(
          padding: EdgeInsets.only(
            left: SizeConfig.blockSizeHorizontal! * 3,
            right: SizeConfig.blockSizeHorizontal! * 3,
          ),
          child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
              child: const Text("画面カスタマイズ",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold))),
        ),
      ]),
      switchWidget(todaysScheduleListView(),
          ConfigDataLoader().searchConfigData("todaysSchedule", ref)),
      switchWidget(
          taskDataListList(
              ConfigDataLoader().searchConfigInfo("taskList", ref)),
          ConfigDataLoader().searchConfigData("taskList", ref)),
      switchWidget(
          Column(children: [
            MoodleUrlLauncher(width: 100),
            const SizedBox(height: 5)
          ]),
          ConfigDataLoader().searchConfigData("moodleLink", ref)),
      Screenshot(
          controller: _screenShotController,
          child: SizedBox(
              child: Container(
                  height: SizeConfig.blockSizeVertical! * 85,
                  decoration: switchDecoration(),
                  child: Column(children: [
                    Row(children: [
                      IconButton(
                          onPressed: () {
                            decreasePgNumber();
                          },
                          icon: const Icon(Icons.arrow_back_ios),
                          iconSize: 20),
                      Text(
                        targetMonth,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              increasePgNumber();
                            });
                          },
                          icon: const Icon(Icons.arrow_forward_ios),
                          iconSize: 20),
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
                                    builder: (context) => TagAndTemplatePage()),
                              );
                            },
                            icon: const Icon(Icons.tag,
                                size: 15, color: Colors.white),
                            label: const Text('タグとテンプレート',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.blueAccent),
                            ),
                          ),
                        ),
                      )),
                      showOnlyScreenShot(LogoAndTitle(size: 7))
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
                    ])
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
        menuList(Icons.calendar_month, "カレンダー", [

            menuListChild(Icons.groups_rounded, "予定の配信/受信", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DataUploadPage()),
              );
            }),

          // scheduleEmptyFlag(
          //   ref,
          //   menuListChild(Icons.school, "年間行事予定", () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => UnivSchedulePage()),
          //     );
          //   }),
          // )

          // scheduleEmptyFlag(
          //   ref,
          //   menuListChild(Icons.ios_share_rounded, "SNS共有コンテンツ",
          //       () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => SnsContentsPage()),
          //     );
          //   }),
          // )
        ]),
        const SizedBox(height: 15),
        tagEmptyFlag(
          ref,
          expandedMenuPanel(Icons.currency_yen, "アルバイト", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ArbeitStatsPage(
                        targetMonth: targetMonth,
                      )),
            );
          }),
        ),
        const SizedBox(height: 15),
        Row(children: [
          menuPanel(
            Icons.link_rounded, 
            "Moodle URL登録", 
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UrlRegisterPage()),
              );
            }
          ),
          SizedBox(
            width: SizeConfig.blockSizeHorizontal! * 5,
          ),
          menuPanel(Icons.lightbulb, "使い方ガイド", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HowToUsePage()),
            );
          })
        ]),
        const SizedBox(height: 15),
        menuList(Icons.info, "その他", [

          menuListChild(Icons.backup, "データバックアップ", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DataDownloadPage()),
            );
          }),

          
          menuListChild(Icons.settings, "設定", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          }),

          menuListChild(Icons.info, "サポート", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SnsLinkPage()),
            );

          })

          
        ]),
        const SizedBox(height: 15),
        const SizedBox(height: 30),
      ])
    ]);
  }

  Widget calendarShareButton(BuildContext context) {
    return FloatingActionButton(
        heroTag: "calendar_2",
        backgroundColor: MAIN_COLOR,
        child: const Icon(Icons.ios_share, color: Colors.white),
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
        increasedMonth = year.toString() + "/" + "01";
      });
    } else {
      int month = int.parse(targetMonth.substring(5, 7));
      month += 1;
      setState(() {
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
        decreasedMonth = year.toString() + "/" + "12";
      });
    } else {
      int month = int.parse(targetMonth.substring(5, 7));
      month -= 1;
      setState(() {
        decreasedMonth =
            targetMonth.substring(0, 5) + month.toString().padLeft(2, '0');
      });
    }

    targetMonth = decreasedMonth;
    generateCalendarData();
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
            width: SizeConfig.blockSizeHorizontal! * 13.571, //14.285,
            height: SizeConfig.blockSizeVertical! * 2,
            child: Center(
                child: Text(
              days.elementAt(index),
              style: const TextStyle(color: Colors.grey),
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
            style: const TextStyle(color: Colors.red, fontSize: 10),
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
        width: SizeConfig.blockSizeHorizontal! * 13.571, //14.285,
        child: ListView.builder(
          itemBuilder: (context, index) {
            DateTime target =
                generateCalendarData()[dayOfWeek]!.elementAt(index);
            return InkWell(
              child: Container(
                  width: SizeConfig.blockSizeHorizontal! * 13.571, //14.285,
                  height: SizeConfig.blockSizeVertical! * 12,
                  decoration: BoxDecoration(
                    color: cellColour(target),
                    border: Border.all(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(children: [
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(target.day.toString())),
                          const Spacer(),
                          doNotContainScreenShot(taskListLength(target, 9.0)),
                          const SizedBox(width: 3)
                        ]),
                        const Divider(
                          height: 0.7,
                          indent: 2,
                          endIndent: 2,
                          thickness: 0.7,
                        ),
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
      return const Color.fromRGBO(255, 204, 204, 1);
    } else if (target.month != targetmonthDT.month) {
      return const Color.fromARGB(255, 242, 242, 242);
    } else if (isHoliday.elementAt(target.day) &&
        ConfigDataLoader().searchConfigData("holidayPaint", ref) == 1) {
      return const Color.fromARGB(255, 255, 239, 239);
    } else if (target.weekday == 6 &&
        ConfigDataLoader().searchConfigData("holidayPaint", ref) == 1) {
      return const Color.fromARGB(255, 227, 238, 255);
    } else if (target.weekday == 7 &&
        ConfigDataLoader().searchConfigData("holidayPaint", ref) == 1) {
      return const Color.fromARGB(255, 255, 239, 239);
    } else {
      return Colors.white;
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
                color: Colors.white,
                fontSize: fontSize),
          ));
    }
  }

  Widget calendarCellsChild(DateTime target) {
    Widget dateTimeData = Container();
    final data = ref.watch(calendarDataProvider);
    String targetKey = target.year.toString() +
        "-" +
        target.month.toString().padLeft(2, "0") +
        "-" +
        target.day.toString().padLeft(2, "0");
    if (data.sortedDataByDay.keys.contains(targetKey)) {
      List<dynamic> targetDayData = data.sortedDataByDay[targetKey];
      return SizedBox(
          child: ListView.separated(
              itemBuilder: (context, index) {
                if (targetDayData.elementAt(index)["startTime"].trim() != "" &&
                    targetDayData.elementAt(index)["endTime"].trim() != "") {
                  dateTimeData = Text(
                    " " +
                        targetDayData.elementAt(index)["startTime"] +
                        "～" +
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
                                        color: Colors.black, fontSize: 8),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              ])
                        ])),
                    targetDayData.elementAt(index)["isPublic"]);
              },
              separatorBuilder: (context, index) {
                return publicContainScreenShot(
                    const Divider(
                      height: 0.7,
                      indent: 2,
                      endIndent: 2,
                      thickness: 0.7,
                    ),
                    targetDayData.elementAt(index)["isPublic"]);
              },
              itemCount: targetDayData.length,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics()));
    } else {
      return const Center();
    }
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0), // 角丸の半径を指定
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5), // 影の色と透明度
              spreadRadius: 2, // 影の広がり
              blurRadius: 3, // ぼかしの強さ
              offset: const Offset(0, 3), // 影の方向（横、縦）
            ),
          ],
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0), // 角丸の半径を指定
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5), // 影の色と透明度
              spreadRadius: 2, // 影の広がり
              blurRadius: 3, // ぼかしの強さ
              offset: const Offset(0, 3), // 影の方向（横、縦）
            ),
          ],
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
              width: SizeConfig.blockSizeHorizontal! * 95,
              height: SizeConfig.blockSizeVertical! * 6,
              color: Colors.white,
              child: Center(
                  child: Row(children: [
                const SizedBox(width: 30),
                Icon(icon, color: MAIN_COLOR, size: 40),
                const Spacer(),
                Text(text,
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal! * 5,
                    )),
                const Spacer(),
              ]))),
          const Divider(height: 1)
        ]));
  }

  Widget menuListIndex(String text) {
    return Column(children: [
      Container(
          width: SizeConfig.blockSizeHorizontal! * 95,
          height: SizeConfig.blockSizeVertical! * 4,
          color: Colors.white,
          child: Center(
              child: Row(children: [
            const SizedBox(width: 30),
            Text(text,
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal! * 5,
                  color: Colors.grey
                )),
            const Spacer(),
          ]))),
      const Divider(height: 1)
    ]);
  }

  Widget menuList(IconData headerIcon, String headerText, List<Widget> child) {
    return Container(
        width: SizeConfig.blockSizeHorizontal! * 95,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0), // 角丸の半径を指定
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5), // 影の色と透明度
              spreadRadius: 2, // 影の広がり
              blurRadius: 3, // ぼかしの強さ
              offset: const Offset(0, 3), // 影の方向（横、縦）
            ),
          ],
        ),
        child: Column(children: [
          SizedBox(
              height: SizeConfig.safeBlockVertical! * 2,
              child: Row(children: [
                const SizedBox(width: 10),
                Icon(headerIcon,
                    size: SizeConfig.safeBlockVertical! * 1.5,
                    color: Colors.grey),
                Text(
                  headerText,
                  style: TextStyle(
                      fontSize: SizeConfig.safeBlockVertical! * 1.5,
                      color: Colors.grey),
                )
              ])),
          const Divider(height: 1),
          ListView.builder(
            itemBuilder: (context, index) {
              return child.elementAt(index);
            },
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: child.length,
          ),
          SizedBox(height: SizeConfig.safeBlockVertical! * 2),
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
          content = "「このアプリいいね」と君が思うなら\n" + today + "は シェアだ記念日";
        // "公式サイトにてみんなの授業課題データベースが公開中！楽単苦単をチェック\n＞＞『使い方ガイドとサポート』から";
        case 3:
          content = "お問い合わせやほしい機能はわせジュール公式サイトまで \n＞＞『使い方ガイドとサポート』から";
        case 4:
          content = "「このアプリいいね」と君が思うなら\n" + today + "は シェアだ記念日";
        //"友達とシェアして便利！「SNS共有コンテンツ」をチェック  \n＞＞『SNS共有コンテンツ』から";
        case 5:
          content = "カレンダーテンプレート機能で、いつもの予定を楽々登録！ \n＞＞『# タグとテンプレート』から";
        case 6:
          content = "カレンダーは複数日登録に対応！  \n＞＞『+』ボタンから";
        case 7:
          content = "「このアプリいいね」と君が思うなら\n" + today + "は シェアだ記念日";
        case 8:
          content = "運営公式SNSで最新情報をチェック！  \n＞＞『サポート』から";
        case 9:
          content = "重要タスクやスケジュールは通知でお知らせ！ \n＞＞『設定』から";
        case 10:
          content = "毎日お疲れ様です！";
      }
    }

    return Padding(
        padding: EdgeInsets.only(top: SizeConfig.blockSizeHorizontal! * 2),
        child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HowToUsePage()),
              );
            },
            child: Container(
              width: SizeConfig.blockSizeHorizontal! * 95,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(12.5), // 角丸の半径を指定
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5), // 影の色と透明度
                    spreadRadius: 2, // 影の広がり
                    blurRadius: 3, // ぼかしの強さ
                    offset: const Offset(0, 3), // 影の方向（横、縦）
                  ),
                ],
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
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10),
                        ),
                        const Divider(color: Colors.white, height: 2),
                        Text(
                          content,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12.5),
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
      return const BoxDecoration(color: Colors.white);
    } else {
      return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0), // 角丸の半径を指定
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5), // 影の色と透明度
            spreadRadius: 2, // 影の広がり
            blurRadius: 3, // ぼかしの強さ
            offset: const Offset(0, 3), // 影の方向（横、縦）
          ),
        ],
      );
    }
  }

  Widget todaysScheduleListView() {
    DateTime target = DateTime.now();
    final data = ref.read(calendarDataProvider);
    ref.watch(calendarDataProvider);
    String targetKey = target.year.toString() +
        "-" +
        target.month.toString().padLeft(2, "0") +
        "-" +
        target.day.toString().padLeft(2, "0");

    if (data.sortedDataByDay[targetKey] == null) {
      return const SizedBox();
    } else {
      List targetDayData = data.sortedDataByDay[targetKey];
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'きょうの予定',
          style: TextStyle(
              fontSize: SizeConfig.blockSizeHorizontal! * 7,
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
        ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            Widget dateTimeData = Container();
            if (targetDayData.elementAt(index)["startTime"].trim() != "" &&
                targetDayData.elementAt(index)["endTime"].trim() != "") {
              dateTimeData = Text(
                " " +
                    targetDayData.elementAt(index)["startTime"] +
                    "～" +
                    targetDayData.elementAt(index)["endTime"],
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              );
            } else if (targetDayData.elementAt(index)["startTime"].trim() !=
                "") {
              dateTimeData = Text(
                " " + targetDayData.elementAt(index)["startTime"],
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              );
            } else {
              dateTimeData = const Text(
                " 終日",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              );
            }

            return Column(children: [
              InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return DailyViewPage(target: target);
                      });
                },
                child: Container(
                    width: SizeConfig.blockSizeHorizontal! * 95,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5), // 影の色と透明度
                          spreadRadius: 2, // 影の広がり
                          blurRadius: 3, // ぼかしの強さ
                          offset: const Offset(0, 3), // 影の方向（横、縦）
                        ),
                      ],
                    ),
                    child: Row(children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              dateTimeData,
                              const SizedBox(width: 15),
                              SizedBox(
                                  child: tagChip(
                                      targetDayData.elementAt(index)["tagID"],
                                      ref))
                            ]),
                            SizedBox(
                                width: SizeConfig.blockSizeHorizontal! * 70,
                                child: Text(
                                  data.sortedDataByDay[targetKey]
                                      .elementAt(index)["subject"],
                                  overflow: TextOverflow.clip,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                ))
                          ]),
                    ])),
              ),
              const SizedBox(height: 15)
            ]);
          },
          itemCount: data.sortedDataByDay[targetKey].length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        )
      ]);
    }
  }

  Widget taskDataListList(int fromNow) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ListView.builder(
        itemBuilder: (context, index) {
          DateTime targetDay = today.add(Duration(days: index));
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [taskDataList(targetDay, index)]);
        },
        itemCount: fromNow,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
      SizedBox(height: SizeConfig.blockSizeVertical! * 1)
    ]);
  }

  Widget taskDataList(DateTime target, int fromNow) {
    final taskData = ref.watch(taskDataProvider);
    Map<DateTime, List<Map<String, dynamic>>> sortedData =
        taskData.sortDataByDtEnd(taskData.taskDataList);
    Widget title = const SizedBox();

    if (sortedData.keys.contains(target)) {
      if (fromNow == 0) {
        title = Text(
          '近日締切の課題',
          style: TextStyle(
              fontSize: SizeConfig.blockSizeHorizontal! * 7,
              color: Colors.white,
              fontWeight: FontWeight.bold),
        );
      }

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        title,
        Text("$fromNow日後",
            style: const TextStyle(color: Colors.white, fontSize: 18)),
        ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            Widget dateTimeData = Container();
            dateTimeData = Text(
              sortedData[target]!.elementAt(index)["title"],
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
            );

            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: SizeConfig.blockSizeHorizontal! * 95,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white, // コンテナの背景色
                      borderRadius: BorderRadius.circular(12.0), // 角丸の半径
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5), // 影の色と透明度
                          spreadRadius: 2, // 影の広がり
                          blurRadius: 4, // 影のぼかし
                          offset: const Offset(0, 2), // 影の方向（横、縦）
                        ),
                      ],
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          dateTimeData,
                          Text(
                            sortedData[target]!.elementAt(index)["summary"] ??
                                "(詳細なし)",
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                          )
                        ]),
                  ),
                  const SizedBox(height: 7)
                ]);
          },
          itemCount: sortedData[target]!.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        )
      ]);
    } else {
      if (fromNow == 0 && !isTaskDatanull(target)) {
        title = Text(
          '近日締切の課題',
          style: TextStyle(
              fontSize: SizeConfig.blockSizeHorizontal! * 7,
              color: Colors.white,
              fontWeight: FontWeight.bold),
        );
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
