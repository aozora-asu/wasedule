import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:flutter_calandar_app/backend/DB/db_Manager.dart';
import 'package:flutter_calandar_app/backend/http_request.dart';

import "../../../backend/temp_file.dart";
import '../../size_config.dart';
import '../../colors.dart';
import 'task_page.dart';

class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  Future<Map<String, dynamic>>? events;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await resisterTaskToDB(url_t);
    setState(() {
      events = Future.value(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: events,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else if (snapshot.hasData) {
              // データが読み込まれた場合、リストを生成
              return buildDataCards(
                  snapshot.data!["events"] as List<Map<String, dynamic>>);
            } else {
              // データがない場合の処理（nullの場合など）
              return CircularProgressIndicator();
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _loadData();
        },
        child: Icon(Icons.get_app), // ボタンのアイコン
        backgroundColor: MAIN_COLOR, // ボタンの背景色
      ),
    );
  }
}




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
          title:Center(
             child: 
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
              ]
            ),
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
      body:
       ListView(children:[
        TableCalendar<dynamic>(
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
      SizedBox(
        height:13,
      ),
      TaskList()
     ]
   ),
  );
 }
}

class EventData {
  String dtEnd;
  String description;
  String memo;

  EventData(this.dtEnd, this.description, this.memo);
}

// void main() {
//   List<EventData> events = [
//     EventData('2023-10-22 03:59:00.000', '#1 アンケート', null),
//     EventData('2023-10-23 00:00:00.000', '#2 アンケート', null),
//     EventData('2023-10-05 05:00:00.000', '質問申請フォーム/Question Application Form', null),
//   ];

//   for (var event in events) {
//     print('dtEnd: ${event.dtEnd}, description: ${event.description}, memo: ${event.memo}');
//   }
// }

class TaskList extends StatelessWidget {
  
 @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Column(
      children:[Card(
       color: WIDGET_COLOR,
        child: SizedBox(
         height: SizeConfig.blockSizeHorizontal! * 37,
         width: SizeConfig.blockSizeHorizontal! * 98,
         child:Column(
          children:[
             Text(
              ' ～現在の授業課題～',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! * 3.5,
                fontWeight: FontWeight.w800,
                color: const Color.fromARGB(255, 77, 46, 35),
              ),
            ),
            Container(
              height: SizeConfig.blockSizeHorizontal! * 30,
              width: SizeConfig.blockSizeHorizontal! * 96,
              decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
               BoxShadow(
                  color: Colors.grey,
                ),
                BoxShadow(
                  color: Colors.white,
                  spreadRadius: -1.5,
                  blurRadius: 2.0,
                ),
              ],                      
            ),
            child:ListView(
              children: [
                   Text("なななななななななななななななななななななななななななな")
                ],
         )
        )
       ]
      )
     )
    )
   ]
  );
 }
}