import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/screens/components/organism/bottomBar.dart';

import './screens/pages/calendar_page.dart';
import './screens/pages/task_page.dart';
import './colors.dart';
import './screens/components/organism/appBar.dart';
import './screens/components/organism/bottomBar.dart';

//主に画面の遷移などに関する処理をまとめるもの

class FirstPage extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
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
      body = Calendar();
    } else {
      body = TaskPage();
    }

    return Scaffold(
      appBar: const CustomAppBar(),
      body: body,
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
