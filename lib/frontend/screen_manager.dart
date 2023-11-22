import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/screens/components/organism/bottom_bar.dart';

import './screens/pages/calendar_page.dart';
import './screens/pages/task_page.dart';

import 'screens/components/organism/app_bar.dart';
import 'screens/components/organism/burger_menu.dart';
//主に画面の遷移などに関する処理をまとめるもの

class AppPage extends StatefulWidget {
  const AppPage({
    Key? key,
  }) : super(key: key);
  @override
  _AppPageState createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  int _currentIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_currentIndex == 0) {
      body = const Calendar();
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
