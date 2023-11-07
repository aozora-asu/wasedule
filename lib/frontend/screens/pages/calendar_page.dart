import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/database_helper.dart';

import '../components/template/brief_task_text.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../size_config.dart';

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
      body: ListView(children: [
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
                  style: const TextStyle(
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
                  style: const TextStyle(
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
                  style: const TextStyle(
                    color: Colors.black87,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(
          height: 13,
        ),
        briefTaskList()
      ]),
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

class briefTaskList extends StatelessWidget {
  TaskDatabaseHelper databaseHelper = TaskDatabaseHelper();
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Column(children: [
      Card(
          color: const Color.fromARGB(255, 254, 230, 230),
          child: SizedBox(
              height: SizeConfig.blockSizeHorizontal! * 60,
              width: SizeConfig.blockSizeHorizontal! * 98,
              child: Column(children: [
                Text(
                  ' ～現在のタスク～',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal! * 3.5,
                    fontWeight: FontWeight.w800,
                    color: const Color.fromARGB(255, 77, 46, 35),
                  ),
                ),
                Container(
                    height: SizeConfig.blockSizeHorizontal! * 50,
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
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: databaseHelper.taskListForCalendarPage(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // 読み込み中の場合、ProgressIndicator を表示
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          // エラーがある場合、エラーメッセージを表示
                          return Text("Error: ${snapshot.error}");
                        } else {
                          // データがある場合、buildTaskText 関数を呼び出してデータを表示
                          return buildTaskText(snapshot.data ?? [], context);
                        }
                      },
                    ))
              ])))
    ]);
  }
}
