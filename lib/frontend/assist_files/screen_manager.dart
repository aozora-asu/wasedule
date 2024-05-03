import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_calandar_app/frontend/screens/common/bottom_bar.dart';
import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/moodle_view_page.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/timetable_page.dart';

import '../screens/calendar_page/calendar_page.dart';
import '../screens/to_do_page/to_do_page.dart';
import '../screens/task_page/task_view_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/common/app_bar.dart';
import '../screens/common/burger_menu.dart';
import '../screens/task_page/task_data_manager.dart';
//主に画面の遷移などに関する処理をまとめるもの

class AppPage extends ConsumerStatefulWidget {
  int ? initIndex;
  AppPage({
    this.initIndex,
    Key? key,
  }) : super(key: key);
  @override
  _AppPageState createState() => _AppPageState();
}

class _AppPageState extends ConsumerState<AppPage> {
  int _currentIndex =0;
  PageController pageController =  PageController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initIndex ?? 2;
    pageController = PageController(initialPage:widget.initIndex ?? 2);
  }

  void _onItemTapped(int index) {
    ref.read(taskDataProvider).isInit = true;
    setState(() {
      _currentIndex = index;
    });
    pageController.jumpToPage(index);
  }

  ScrollPhysics physics = const ScrollPhysics();
  bool isExtendBody = true;
  bool isExtendBottom = true;
  bool showAppBar = true;
  Timer? _timer;

  Widget pageView(){
    return PageView(
        physics: physics,
        controller: pageController,
        children: [TaskPage(),
                   TimeTablePage(),
                   const Calendar(),
                   TaskViewPage(),
                   MoodleViewPage(),
                   ],
        onPageChanged: (value){
            if(value == 4){
              isExtendBottom = false;
              isExtendBody = false;
              physics = const NeverScrollableScrollPhysics();
            }else if(value == 1 || value == 2){
              isExtendBody = true;
              isExtendBottom = true;
              physics = const ScrollPhysics();
            }else{
              isExtendBody = false;
              isExtendBottom = true;
              physics = const ScrollPhysics();
            }
            setState((){
              _currentIndex = value;
            });
        },
    );
  }

  @override
  Widget build(BuildContext context) {
  ref.watch(taskDataProvider);
  Widget body;
  body = pageView();

    return Scaffold(
      extendBodyBehindAppBar: isExtendBody,
      extendBody: isExtendBottom,
      appBar: CustomAppBar(backButton: false),
      bottomNavigationBar:customBottomBar(
          context,
          _currentIndex,
          _onItemTapped,
          setState
        ),
      body: body,
    );
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 4), () {
      setState(() {
       if(_currentIndex != 3){
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
