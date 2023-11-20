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
  Future<List<Map<String, dynamic>>> _getDataSource() async {
    Future<List<Map<String, dynamic>>> scheduleList =
        ScheduleDatabaseHelper().getScheduleFromDB();
    final List<Event> event = <Event>[];
    final DateTime today = DateTime.now();
    final DateTime startTime =
        DateTime(today.year, today.month, today.day, 9, 0, 0);
    final DateTime endTime = startTime.add(const Duration(hours: 2));
    event.add(Event('大学', startTime, endTime, ACCENT_COLOR, false));
    return scheduleList;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: SizeConfig.blockSizeHorizontal! * 200,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _getDataSource(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // データが取得される間、ローディングインディケータを表示できます。
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    // エラーがある場合、エラーメッセージを表示します。
                    return Text('エラーだよい: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // データがないか、データが空の場合、メッセージを表示できます。
                    return Text('利用可能なイベントはありません。');
                  } else {
                    // データが利用可能な場合、取得したデータを使用してカレンダーを構築します。
                    final List<Map<String, dynamic>> scheduleList =
                        snapshot.data!;
                    final List<Event> events = <Event>[];

                    // スケジュールリストからイベントを作成するか、必要に応じて変更してください。
                    for (var schedule in scheduleList) {
                    // スケジュールデータを解析し、Event オブジェクトを作成します。
                      
                      DateTime combineStartDateAndTime() {
                      // 開始日と時刻の結合
                      DateTime startDate = schedule['startDate'];
                      DateTime startTime = schedule['startTime'];
                      DateTime combinedStartDateTime = DateTime(startDate.year, startDate.month, startDate.day);
                      combinedStartDateTime = combinedStartDateTime.add(Duration(hours: startTime.hour, minutes: startTime.minute));
                      print(combinedStartDateTime);
                      return combinedStartDateTime;
                      }

                      DateTime combineEndDateAndTime() {
                      // 終了日と時刻の結合
                      DateTime endDate = schedule['endDate'];
                      DateTime endTime = schedule['endTime'];
                      DateTime combinedEndDateTime = DateTime(endDate.year, endDate.month, endDate.day);
                      combinedEndDateTime = combinedEndDateTime.add(Duration(hours: endTime.hour, minutes: endTime.minute));
                      print(combinedEndDateTime);
                      return combinedEndDateTime;
                      }

                      bool setIsAllDay() {
                      //startTimeとendTimeのどちらも空だった場合にtrueを返す
                      if(schedule['startTime']=="" && schedule['endTime']==""){
                        return true;
                        }else{
                        return false;  
                        }
                      }

                     //整形したデータをカレンダー表示用のリストにぶち込む
                       final String eventName = schedule['eventName'];
                       final DateTime from = combineStartDateAndTime();
                       final DateTime to = combineEndDateAndTime();
                       const Color background = ACCENT_COLOR;
                       final bool isAllDay = setIsAllDay();
                       events.add(Event(eventName, from, to, background, isAllDay));
                    }

                    return SfCalendar(
                      view: CalendarView.month,
                      backgroundColor: BACKGROUND_COLOR,
                      todayHighlightColor: MAIN_COLOR,
                      showNavigationArrow: true,
                      selectionDecoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: MAIN_COLOR, width: 3),
                      ),
                      onTap: (CalendarTapDetails details) {
                        print("カレンダーがタップされた");
                      },
                      monthViewSettings: MonthViewSettings(
                        showAgenda: true,
                        appointmentDisplayMode:
                            MonthAppointmentDisplayMode.appointment,
                      ),
                      dataSource: EventDataSource(events),
                    );
                  }
                },
              ),
            ),
            briefTaskList(),
          ],
        ),
      ),
      floatingActionButton: AddEventButton(),
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
