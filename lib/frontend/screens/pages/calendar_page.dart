import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/database_helper.dart';
import 'package:flutter_calandar_app/frontend/colors.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../components/template/brief_task_text.dart';
import '../../size_config.dart';
import '../components/template/add_event_button.dart';
import '../components/template/event.dart';
import '../components/template/loading.dart';

import 'dart:async';
import 'dart:io';
// ignore: unnecessary_import

import 'package:flutter/cupertino.dart';

import '../../../backend/notify/notify_setting.dart';
import '../../../backend/DB/models/notify_content.dart';
import '../../../backend/notify/notify.dart';

class Calendar extends StatefulWidget {
  const Calendar({
    Key? key,
  }) : super(key: key);
  // final NotificationAppLaunchDetails? notificationAppLaunchDetails;
  // bool get didNotificationLaunchApp =>
  //     notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  bool _notificationsEnabled = false;
  final StreamController<ScheduleNotification>
      didScheduleLocalNotificationStream =
      StreamController<ScheduleNotification>.broadcast();
  @override
  void initState() {
    super.initState();
    _isAndroidPermissionGranted();
    _requestPermissions();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
    testNotify();
  }

  testNotify() async {
    //await Notify().repeatNotification();
    await Notify().scheduleDailyEightAMNotification();
  }

  Future<void> _isAndroidPermissionGranted() async {
    final bool granted = await isAndroidPermissionGranted();
    setState(() {
      _notificationsEnabled = granted;
    });
  }

  Future<void> _requestPermissions() async {
    final bool? grantedNotificationPermission = await requestPermissions();
    setState(() {
      _notificationsEnabled = grantedNotificationPermission ?? false;
    });
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didScheduleLocalNotificationStream.stream
        .listen((ScheduleNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const Calendar(),
                  ),
                );
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  //通知からアプリを開いた時の処理
  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payload) async {
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) => const Calendar(),
      ));
    });
  }

  @override
  void dispose() {
    didScheduleLocalNotificationStream.close();
    selectNotificationStream.close();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _getDataSource() async {
    List<Map<String, dynamic>> scheduleList =
        await ScheduleDatabaseHelper().getScheduleFromDB();
    return scheduleList;
  }

  bool setIsAllDay(Map<String, dynamic> schedule) {
    //startTimeとendTimeのどちらも空だった場合にtrueを返す
    if (schedule['startTime'] == null && schedule['endTime'] == null) {
      return true;
    } else {
      return false;
    }
  }

  Widget emptyCalendar() {
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
      monthViewSettings: const MonthViewSettings(
        showAgenda: true,
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: SizeConfig.blockSizeHorizontal! * 200,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _getDataSource(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // データが取得される間、ローディングインディケータを表示できます。
                    return LoadingScreen();
                  } else if (snapshot.hasError) {
                    // エラーがある場合、エラーメッセージを表示します。
                    return Text('エラーだよい: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // データがないか、データが空の場合、空っぽのカレンダーを表示。
                    return emptyCalendar();
                  } else {
                    // データが利用可能な場合、取得したデータを使用してカレンダーを構築します。
                    final List<Map<String, dynamic>> scheduleList =
                        snapshot.data!;
                    final List<Event> events = <Event>[];

                    // スケジュールリストからイベントを作成するか、必要に応じて変更してください。
                    for (var schedule in scheduleList) {
                      //整形したデータをカレンダー表示用のリストにぶち込む
                      final String eventName = schedule['subject'];
                      final DateTime from = schedule["startTime"] != null
                          ? DateTime.parse(schedule['startDate'] +
                              " " +
                              schedule['startTime'])
                          : DateTime.parse(
                              schedule['startDate'] + " " + "00:00");
                      final DateTime to = schedule["endTime"] != null
                          ? DateTime.parse(
                              schedule['endDate'] + " " + schedule['endTime'])
                          : DateTime.parse(schedule['endDate'] + " " + "00:00");

                      const Color background = ACCENT_COLOR;
                      final bool isAllDay = setIsAllDay(schedule);

                      events.add(
                          Event(eventName, from, to, background, isAllDay));
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
                      monthViewSettings: const MonthViewSettings(
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
            BriefTaskList(),
          ],
        ),
      ),
      floatingActionButton: AddEventButton(),
    );
  }
}
