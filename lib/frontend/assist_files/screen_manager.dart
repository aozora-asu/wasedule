import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/screens/common/bottom_bar.dart';
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
    _currentIndex = widget.initIndex ?? 0;
    pageController = PageController(initialPage:widget.initIndex ?? 0);
  }


  void _onItemTapped(int index) {
    ref.read(taskDataProvider).isInit = true;
    setState(() {
      _currentIndex = index;
    });
    pageController .jumpToPage(index);
  }

  Widget pageView(){
    return PageView(
        controller: pageController ,
        children: [//TimeTablePage(),
                   const Calendar(),
                   TaskViewPage(),
                   TaskPage(),],
        onPageChanged: (value){
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
      appBar: CustomAppBar(backButton: false,),
      drawer: burgerMenu(),
      bottomNavigationBar: customBottomBar(
         _currentIndex,
         _onItemTapped,
         setState
      ),
      body: body,
    );
  }
}
