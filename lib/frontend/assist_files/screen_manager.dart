import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/screens/common/bottom_bar.dart';

import '../screens/calendar_page/calendar_page.dart';
import '../screens/to_do_page/to_do_page.dart';
import '../screens/task_page/task_view_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/common/app_bar.dart';
import '../screens/common/burger_menu.dart';
import 'data_manager.dart';
//主に画面の遷移などに関する処理をまとめるもの

class AppPage extends ConsumerStatefulWidget {
  const AppPage({
    Key? key,
  }) : super(key: key);
  @override
  _AppPageState createState() => _AppPageState();
}

class _AppPageState extends ConsumerState<AppPage> {
  int _currentIndex = 0;
  void _onItemTapped(int index) {
    ref.read(taskDataProvider).isInit = true;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
  ref.watch(taskDataProvider);
    Widget body;
    if (_currentIndex == 0) {
      body = const Calendar();
    } else if (_currentIndex == 2){
      ref.read(taskDataProvider).taskPageIndex = 0;
      body = TaskViewPage();
    } else {
      body = TaskPage();
    }

    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: burgerMenu(),
      body: body,
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
