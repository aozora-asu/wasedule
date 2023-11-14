import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/database_helper.dart';
import 'package:flutter_calandar_app/frontend/colors.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../components/template/brief_task_text.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../size_config.dart';
import '../components/template/add_event_button.dart';


class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {


  @override
  Widget build(BuildContext context) {
        SizeConfig().init(context);
    return Scaffold(
        body:SingleChildScrollView(child:Column(children: [Container(
      height: SizeConfig.blockSizeHorizontal! * 200,
      child:SfCalendar(
      view: CalendarView.month,
      backgroundColor: BACKGROUND_COLOR,
      todayHighlightColor: ACCENT_COLOR,
      showNavigationArrow: true,
      selectionDecoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: MAIN_COLOR,width: 3),),
      onTap: (CalendarTapDetails details) {
                  print("Hello,World!");
                },
      monthViewSettings: MonthViewSettings(
        showAgenda: true,
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
      ),
      dataSource: EventDataSource(_getDataSource()),
      
    ),
    ),briefTaskList()
    ])
    ),
     floatingActionButton:InputForm(),
    );
  }
} 
// void main() {
  // List events = [
  //   ('2023-10-22 03:59:00.000', '#1 アンケート', null),
  //   ('2023-10-23 00:00:00.000', '#2 アンケート', null),
  //   ('2023-10-05 05:00:00.000', '質問申請フォーム/Question Application Form', null),
  // ];

//   for (var event in events) {
//     print('dtEnd: ${event.dtEnd}, description: ${event.description}, memo: ${event.memo}');
//   }
// }

class Event {
  Event(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}

List<Event> _getDataSource() {
  final List<Event> event = <Event>[];
  final DateTime today = DateTime.now();
  final DateTime startTime =
      DateTime(today.year, today.month, today.day, 9, 0, 0);
  final DateTime endTime = startTime.add(const Duration(hours: 2));
  event.add(
      Event('イベント', startTime, endTime, const Color(0xFF0F8644), false));
  return event;
}

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Event> event) {
    appointments = event;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}
























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


