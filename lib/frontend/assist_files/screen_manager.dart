import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/request_app_review.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/screens/common/attendance_dialog.dart';
import 'package:flutter_calandar_app/frontend/screens/common/bottom_bar.dart';
import 'package:flutter_calandar_app/frontend/screens/common/loading.dart';
import 'package:flutter_calandar_app/frontend/screens/common/menu_appbar.dart';
import 'package:flutter_calandar_app/frontend/screens/map_page/wase_map.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/arbeit_stats_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/data_backup_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/schedule_broadcast_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/setting_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/university_schedule.dart';
import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/moodle_view_page.dart';
import 'package:flutter_calandar_app/frontend/screens/mywaseda_view_page/mywaseda_view_page.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/deleted_tasks.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/expired_tasks.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/timetable_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/calendar_page/calendar_page.dart';
import '../screens/to_do_page/to_do_page.dart';
import '../screens/task_page/task_view_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/task_page/task_data_manager.dart';
//主に画面の遷移などに関する処理をまとめるもの

class AppPage extends ConsumerStatefulWidget {
  int? initIndex;
  AppPage({
    this.initIndex,
    super.key,
  });
  @override
  _AppPageState createState() => _AppPageState();
}

class _AppPageState extends ConsumerState<AppPage> {
  int _currentIndex = 0;
  int _currentSubIndex = 0;
  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initIndex ?? 2;
    pageController = PageController(initialPage: 0); //widget.initIndex ?? 2);
    initRateMyApp(context);
    initNotificationTypeSetting();
  }

  Future<void> initNotificationTypeSetting() async {
    final prefs = await SharedPreferences.getInstance();
    bool? isCalendarNotify = prefs.getBool("isCalendarNotify");
    bool? isTaskNotify = prefs.getBool("isTaskNotify");
    bool? isClassNotify = prefs.getBool("isClassNotify");

    if (isCalendarNotify == null) {
      prefs.setBool("isCalendarNotify", true);
    }
    if (isTaskNotify == null) {
      prefs.setBool("isTaskNotify", true);
    }
    if (isClassNotify == null) {
      prefs.setBool("isClassNotify", true);
    }
  }

  void _onItemTapped(int index) {
    ref.read(taskDataProvider).isInit = true;
    setState(() {
      _currentSubIndex = 0;
      _currentIndex = index;
    });
    setPageConfig();
    pageController.jumpToPage(0);
  }

  void setPageConfig() {
    if (_currentIndex == 0) {
      isExtendBody = false;
      isExtendBottom = false;
      physics = const ScrollPhysics();
    } else if (_currentIndex == 1 || _currentIndex == 2) {
      isExtendBody = true;
      isExtendBottom = true;
      physics = const ScrollPhysics();
    } else if (_currentIndex == 3) {
      isExtendBody = false;
      isExtendBottom = true;
      physics = const ScrollPhysics();
    } else if (_currentIndex == 4) {
      isExtendBottom = false;
      isExtendBody = false;
      physics = const NeverScrollableScrollPhysics();
    } else {
      isExtendBody = false;
      isExtendBottom = false;
      physics = const ScrollPhysics();
    }
  }

  void _onSlided(int index) {
    ref.read(taskDataProvider).isInit = true;
    setState(() {
      _currentSubIndex = index;
    });
    pageController.jumpToPage(index);
  }

  void _onTabTapped(int subIndex) {
    ref.read(taskDataProvider).isInit = true;
    setState(() {
      _currentSubIndex = subIndex;
    });
    pageController.jumpToPage(subIndex);
  }

  ScrollPhysics physics = const ScrollPhysics();
  bool isExtendBody = true;
  bool isExtendBottom = true;
  bool showAppBar = true;
  Timer? _timer;
  bool showChildMenu = true;

  void _switchChildMenu() {
    setState(() {
      if (showChildMenu) {
        showChildMenu = false;
      } else {
        showChildMenu = true;
      }
    });
  }

  List<List<Widget>> parentPages() {
    return [
      [const WasedaMapPage()],
      [const TimeTablePage()],
      calendarSubPages(),
      taskSubPages(),
      moodleSubPages(),
    ];
  }

  Widget pageView() {
    return PageView(
      physics: physics,
      controller: pageController,
      children: parentPages().elementAt(_currentIndex),
      onPageChanged: (value) {
        setState(() {
          _currentSubIndex = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(taskDataProvider);
    SizeConfig().init(context);
    Widget body;
    double height = SizeConfig.blockSizeVertical! * 10;
    body = pageView();
    if (_currentSubIndex != 0) {
      isExtendBody = false;
      isExtendBottom = false;
      physics = const ScrollPhysics();
    } else {
      setPageConfig();
    }

    return Scaffold(
        extendBodyBehindAppBar: false,
        extendBody: isExtendBottom,
        appBar: PreferredSize(
            preferredSize: Size(SizeConfig.blockSizeHorizontal! * 100, height),
            child: MenuAppBar(
              currentIndex: _currentIndex,
              onItemTapped: _onItemTapped,
              currentSubIndex: _currentSubIndex,
              onTabTapped: _onTabTapped,
              setosute: setState,
              isChildmenuExpand: showChildMenu,
              changeChildmenuState: _switchChildMenu,
            )),
        bottomNavigationBar:
            customBottomBar(context, _currentIndex, _onItemTapped, setState),
        body: body);
  }

  List<Widget> calendarSubPages() {
    String thisMonth =
        "${DateTime.now().year}/${DateTime.now().month.toString().padLeft(2, '0')}";
    return [
      const Calendar(),
      const DataUploadPage(),
      ArbeitStatsPage(targetMonth: thisMonth),
      const UnivSchedulePage(),
      SettingsPage(isAppBar: false),
      const DataDownloadPage(),
    ];
  }

  List<Widget> taskSubPages() {
    return [
      const TaskViewPage(),
      ExpiredTaskPage(setosute: setState),
      DeletedTaskPage(setosute: setState),
      SettingsPage(
        initIndex: 1,
        isAppBar: false,
      ),
      const TaskPage(),
    ];
  }

  List<Widget> moodleSubPages() {
    return [const MoodleViewPage(), const MyWasedaViewPage()];
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 4), () {
      setState(() {
        if (_currentIndex != 3) {
          showAppBar = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // リソースの解放
    super.dispose();
  }
}
