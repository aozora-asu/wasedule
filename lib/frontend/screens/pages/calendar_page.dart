import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/widgets.dart';

import '../../size_config.dart';
import '../../colors.dart';
import 'task_page.dart';



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
        appBar: AppBar(
          backgroundColor: MAIN_COLOR,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Column(children: <Widget>[
                Text(
                  'わせジュール',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '早稲田生のためのスケジュールアプリ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ]),
            ],
          ),
        ),
        body: body,
        bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        backgroundColor: MAIN_COLOR,
        selectedItemColor: ACCENT_COLOR,
        unselectedItemColor: Colors.white,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'カレンダー',           
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.splitscreen),
            label: 'タスク',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'フレンド',
          ),
        ],
      ),
    );
  }
}



class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TableCalendar<dynamic>(
        firstDay: DateTime.utc(1882, 10, 21),
        lastDay: DateTime.utc(2100, 10, 21),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        calendarBuilders: CalendarBuilders(
          defaultBuilder:
              (BuildContext context, DateTime day, DateTime focusedDay) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              alignment: Alignment.topCenter,
              child: Text(
                day.day.toString(),
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
            );
          },

          /// 有効範囲（firstDay~lastDay）以外の日付部分を生成する
          disabledBuilder:
              (BuildContext context, DateTime day, DateTime focusedDay) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 0.5,
                ),
              ),
              alignment: Alignment.topCenter,
              child: Text(
                day.day.toString(),
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            );
          },
          selectedBuilder:
              (BuildContext context, DateTime day, DateTime focusedDay) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red[800]!,
                  width: 3.0,
                ),
              ),
              alignment: Alignment.topCenter,
              child: Text(
                day.day.toString(),
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}